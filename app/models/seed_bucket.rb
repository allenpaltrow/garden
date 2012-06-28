class SeedBucket < ActiveRecord::Base
   attr_accessible :page_title, :body, :bucket, :seed, :bucket_id, :seed_id, :parent_id, :child_id

   def self.copy_seed(seed_to_copy, destination_bucket, options = {})
      ## Takes one seed_to_copy, one destination_bucket where the seed is being copied to 
      ## Copied seeds must be copied somewhere
      ## the in? parameter indicates whether the copied seed should be accepted (true) or only suggested (false) to the destination bucket

      ## copy_seed takes a preferences hash that can include the following boolean values:
      ##   – :forward_all    (this indicates whether the vine from seed_to_copy to new_seed is all_vine or some_vine)
      ##   – :in_bucket      (this indicates whether the new_seed is put in destination_bucket with containtment.in = true/false)
   
      defaults = {
         in_bucket: false,
         forward_all: false
      }
      preferences = defaults.merge(options)
      if preferences[:forward_all].nil? then
         raise "options hash is not working"
      else 
         puts preferences[:forward_all]
      end
      #in_bucket = preferences[in_bucket]
      #in_bucket ||= false

      #forward_all = preferences[forward_all]
      #forward_all ||= false

      ##  Roots
      new_seed = seed_to_copy.dup                # copy all fields of old seed
      new_seed.parent = seed_to_copy             # new seed has roots to, and is child of, old seed 
      new_seed.save

      ##  Vines
      new_seed.pulls_from << seed_to_copy        # create vine from old bucket to new bucket
      new_vine = Vine.where(puller_id: new_seed.id, pusher_id: seed_to_copy.id).first
      if new_vine.nil? then raise "No vine was created when setting new_seed.pulls_from" 
      else 
         new_vine.forward_all = preferences[:forward_all] 
         new_vine.save  
      end       

      ##  Containment 
      new_seed.bucket = destination_bucket       # put new seed in the destination bucket
      new_containment = Containment.where(bucket_id: destination_bucket.id, seed_id: new_seed.id).first
      if new_containment.nil? then raise "No containment was created when setting new_seed.bucket"
      else new_containment.in_bucket = preferences[:in_bucket]  # set the containment edge's in value based on the in? parameter
         new_containment.save
      end
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
