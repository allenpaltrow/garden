class Vine < ActiveRecord::Base
  # attr_accessible :title, :body
  
  has_many :plants
  
end
