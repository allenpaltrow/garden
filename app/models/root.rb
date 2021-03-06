class Root < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :parent, :child, :parent_id, :child_id
  belongs_to :parent, :foreign_key => "parent_id", :class_name => "SeedBucket"
  belongs_to :child,   :foreign_key => "child_id",   :class_name => "SeedBucket"
  
  validates_uniqueness_of :child_id, :scope => :parent_id, :silent => true
  validate :disallow_self_parenthood 

    def disallow_self_parenthood
      if parent_id == child_id
        errors.add(:parent_id, 'seed cannot be its own parent')
      end
    end
  
end
