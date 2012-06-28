class Vine < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :pusher, :puller, :pusher_id, :puller_id, :forward_all
  belongs_to :pulls_from, :foreign_key => "pusher_id", :class_name => "SeedBucket"
  belongs_to :pushes_to,   :foreign_key => "puller_id",   :class_name => "SeedBucket"
  
  validates_uniqueness_of :pusher_id, :scope => [:puller_id, :forward_all], :silent => true
end
