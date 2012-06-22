class SeedBucket < ActiveRecord::Base
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
          
end
