class Plant < ActiveRecord::Base
  
  attr_accessible :title, :body
  
  has_many :seeds, :class_name => "Plant", :foreign_key => "bucket_id"
  belongs_to :bucket, :class_name => "Plant"
  
  belongs_to :user
  belongs_to :vine

end
