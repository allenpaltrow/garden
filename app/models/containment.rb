class Containment < ActiveRecord::Base
  attr_accessible :title, :body, :bucket, :seed, :bucket_id, :seed_id, :in_bucket
  belongs_to :bucket, :foreign_key => "bucket_id", :class_name => "SeedBucket"
  belongs_to :seed,   :foreign_key => "seed_id",   :class_name => "SeedBucket"
  
  validates_uniqueness_of :seed_id, :scope => :bucket_id, :silent => true
end
