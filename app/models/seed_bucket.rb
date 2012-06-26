class SeedBucket < ActiveRecord::Base
<<<<<<< HEAD
   attr_accessible :page_title, :body, :bucket, :seed, :bucket_id, :seed_id, :parent_id, :child_id

   ######################## The SeedBucket Model####################
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

   ##  If a SeedBucket only hadmany containments, we couldn't represent
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

=======
  attr_accessible :title, :body, :bucket, :seed, :bucket_id, :seed_id
  
  ######################## The SeedBucket Model####################
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
  
  ##  If a SeedBucket only had many containments, we couldn't represent
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

  has_many :seeds, 
          :through => :containment_as_bucket,  
          :uniq => true  # seed can only be in a bucket once
          
  has_many :containment_as_bucket,            
          :foreign_key => "bucket_id", 
          :class_name => "Containment",
          :dependent => :destroy
          
  has_one :bucket, 
          :through => :containment_as_seed
  has_one :containment_as_seed, 
          :foreign_key => "seed_id", 
          :class_name => "Containment",
          :dependent => :destroy
          
>>>>>>> 79270d7d1f9cf68c8b74a27f05046cdbe9c17eb6
end
