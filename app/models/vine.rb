class Vine < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :pusher, :puller, :pusher_id, :puller_id
  belongs_to :pushes_to, :foreign_key => "pusher_id", :class_name => "SeedBucket"
  belongs_to :pulls_from,   :foreign_key => "puller_id",   :class_name => "SeedBucket"
  
  validates_uniqueness_of :pusher_id, :scope => [:puller_id, :all], :message => "There is already a vine here"
end
