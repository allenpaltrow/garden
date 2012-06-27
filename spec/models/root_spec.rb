require 'spec_helper'

describe Root do
   before :each do
      @seed1 = SeedBucket.new; @seed1.save
      @seed2 = SeedBucket.new; @seed2.save
   end
   def number_of_roots_between(seed, bucket)
      return Root.where(parent_id: @seed1.id, child_id: @seed2.id).length 
   end
   it "only creates one root when setting .parent" do
      @seed2.parent = @seed1
      number_of_roots_between(@seed1, @seed2).should be 1
   end
   it "only creates one root for recriprocal parent/child pairing w/ error" do
      @seed2.parent = @seed1
      lambda {@seed1.children << @seed2}.should raise_error
      number_of_roots_between(@seed1, @seed2).should be 1
   end
   it "only one root is made when a child is set to a parent several times w/ error" do
      @seed2.parent = @seed1
      lambda{ 3.times { @seed1.children << @seed2 }}.should raise_error
      number_of_roots_between(@seed1, @seed2).should == 1
   end

   it "removes containment when child is deleted" do
      @seed2.parent = @seed1
      number_of_roots_between(@seed1, @seed2).should == 1
      SeedBucket.destroy(@seed2)
      number_of_roots_between(@seed1, @seed2).should be 0
   end
   it "removes containment when parent is deleted" do
      @seed2.parent = @seed1
      number_of_roots_between(@seed1, @seed2).should == 1
      SeedBucket.destroy(@seed1)
      number_of_roots_between(@seed1, @seed2).should == 0
   end
end

## For seedbucket tests involving .parent and .child
describe SeedBucket do
   before :each do
      @seed1 = SeedBucket.new; @seed1.save
      @seed2 = SeedBucket.new; @seed2.save
   end

   it "shouldn't allow a seed to be its own parent" do
      lambda { @seed1.parent = @seed1 }.should raise_error
   end

end