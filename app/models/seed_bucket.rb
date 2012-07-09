class SeedBucket < ActiveRecord::Base
   attr_accessible :page_title, :body, :bucket, :seed, :bucket_id, :seed_id, :parent, :parent_id, :child, :child_id
   
   def self.seed_copy(seed_to_copy, destination_bucket, options = {})
      new_seed = SeedBucket.recursive_copy_seed(seed_to_copy, destination_bucket, options)
      SeedBucket.push_across_vines(new_seed)
   end
   
   def is_already_in(bucket)
      # To prevent cycles, a seed will only be added to a bucket if that seed has not already been copied to the bucket
      # This method contains the logic for whether one seed is close enough to another to be the same
      # For now, seed1 ~ seed2 if they have 3/3 of the following =  {title, body, origin}
      if bucket.seeds.empty? then return false end 
      bucket.seeds.each do |seed| 
         if self.page_title != seed.page_title then return false end
         if self.body != seed.body then return false end
         if self.origin != seed.origin then return false end
      end 
      return true
   end
   def push_across_vines
      if self.bucket.nil? then return end
      self.bucket.vine_as_pusher.each do |vine| 
         unless self.is_already_in(vine.pushes_to) 
            SeedBucket.recursive_copy_seed(self, vine.pushes_to, {in_bucket: vine.accepts}) #whether seed is accepted to bucket depends on vine.accepts
         end
      end
   end

   def self.recursive_copy_seed(seed_to_copy, destination_bucket, options = {})
      new_seed = SeedBucket.copy_one_seed(seed_to_copy, destination_bucket, options)
      seed_to_copy.seeds.each {|subseed| SeedBucket.recursive_copy_seed(subseed, new_seed, options)}
      new_seed.push_across_vines ## Added this July 9th UNTESTED
      return new_seed
   end

   private
   def self.copy_one_seed(seed_to_copy, destination_bucket, options = {})
      ## Takes one seed_to_copy, one destination_bucket where the seed is being copied to 
      ## Copied seeds must be copied somewhere
      ## the in? parameter indicates whether the copied seed should be accepted (true) or only suggested (false) to the destination bucket

      ## copy_seed takes a preferences hash that can include the following boolean values:
      ##   – :forwards_all    (this indicates whether the vine from seed_to_copy to new_seed is all_vine or some_vine)
      ##   – :in_bucket      (this indicates whether the new_seed is put in destination_bucket with containtment.in = true/false)

      defaults = {
         put_in_bucket: false,
         old_seed_forwards_all: false,
         new_seed_forwards_all: false
      }
      options = defaults.merge(options)   #if any option is nil, replace with false

      ##validate input types
      raise "Seed_to_copy must be a SeedBucket object" unless seed_to_copy.kind_of? SeedBucket
      raise "Destination must be a SeedBucket object" unless destination_bucket.kind_of? SeedBucket

      ## Copy fields
      new_seed = seed_to_copy.dup                # copy all fields of old seed

      ##  Roots
      new_seed.parent = seed_to_copy             # new seed has roots to, and is child of, old seed 
      new_seed.origin = seed_to_copy.origin || seed_to_copy   #sets new origin to Seed_to_copy's origin, unless nil (seed_to_copy)
      new_seed.save

      ##  Vines
      new_seed.pulls_from << seed_to_copy        # create vines from old bucket to new bucket
      new_seed.pushes_to << seed_to_copy
      vine_from_new_to_old = Vine.where(puller_id: seed_to_copy.id, pusher_id: new_seed.id).first
      vine_from_old_to_new = Vine.where(puller_id: new_seed.id, pusher_id: seed_to_copy.id).first
      if vine_from_old_to_new.nil? || vine_from_new_to_old.nil? then raise "There was an error creating vines when setting new_seed.pulls_from" 
      else 
         vine_from_new_to_old.forwards_all = options[:new_seed_forwards_all] 
         vine_from_old_to_new.forwards_all = options[:old_seed_forwards_all] 
         vine_from_old_to_new.save 
         vine_from_new_to_old.save
      end       
      
      ##  Containment 
      new_seed.bucket = destination_bucket       # put new seed in the destination bucket
      new_containment = Containment.where(bucket_id: destination_bucket.id, seed_id: new_seed.id).first
      if new_containment.nil? then raise "No containment was created when setting new_seed.bucket"
      else new_containment.in_bucket = options[:put_in_bucket]  # set the containment edge's in value based on the in? parameter
         new_containment.save
      end
      
      new_seed.save
      return new_seed
   end
   
   before_save do
      #If seed doesn't have an origin, it is its own origin. 
      self.origin ||= self
   end
   
   ######################  The SeedBucket Model ####################
   #################################################################
   ## The SeedBucket is a Node object that is related to other nodes
   ## through various types of edges, which are represented by their 
   ## own models.

   ## SeedBuckets sometime behave like buckets, and contain many 
   ## seeds, while other times behave as seeds, and are contained 
   ## by one bucket. The containment relationship is a directed edge
   ## which relates two SeedBucket objects:

   ##           O ---------------------------> O        =  Seed is 
   ##         Seed         Containment       Bucket        in Bucket

   ##  If a SeedBucket only has_many containments, we couldn't represent
   ##  a digraph. In order to represent direction in the digraph, each 
   ##  SeedBucket hasmany containment_as_bucket and has one 
   ##  containment_as_seed.

   ##  These refer to how the SeedBucket behaves in the relationship
   ##  described by the edge. In the above example:

   ##           O ---------------------------> O       
   ##    Containment_as_seed       Containment_as_bucket
   ##
   ##  However, each SB also has_many seeds and has_one bucket :through
   ##  the two containment relationships. This allows SB.bucket and 
   ##  SB.seeds to return SeedBuckets related to the SB through containments 

   has_one  :bucket, 
            :through => :containment_as_seed
   has_one  :containment_as_seed, 
            :foreign_key => "seed_id", 
            :class_name => "Containment",
            :dependent => :destroy

   has_many :seeds, 
            :through => :containment_as_bucket,  
            :uniq => true  # seed can only be in a bucket once
   has_many :containment_as_bucket,            
            :foreign_key => "bucket_id", 
            :class_name => "Containment",
            :dependent => :destroy

   #############################   ROOTS   ############################# 
   belongs_to  :origin,
            :foreign_key => "origin_id",
            :class_name => "SeedBucket",
            :dependent => :destroy

   has_one  :parent,
            :through => :root_as_child
   has_one  :root_as_child, 
            :foreign_key => "child_id",
            :class_name => "Root",
            :dependent => :destroy

   has_many :children,
            :through => :root_as_parent,
            :uniq => true #parent can only have a particular child once
   has_many :root_as_parent,
            :foreign_key => "parent_id",
            :class_name => "Root",
            :dependent => :destroy

   ###########################   VINES   #############################

   has_many :pulls_from,
            :through => :vine_as_puller
   has_many :vine_as_puller,
            :foreign_key => "puller_id",
            :class_name => "Vine",
            :dependent => :destroy

   has_many :pushes_to,
            :through => :vine_as_pusher
   has_many :vine_as_pusher,
            :foreign_key => "pusher_id",
            :class_name => "Vine",
            :dependent => :destroy
end
