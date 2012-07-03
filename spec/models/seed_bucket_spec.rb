require 'spec_helper'

describe SeedBucket do
   before :each do
      @seedbucket = SeedBucket.new; @seedbucket.save
   end
   describe "#new" do
      it "returns a SeedBucket object" do
         @seedbucket.should be_an_instance_of SeedBucket
      end
   end
   describe "#seed_copy" do
      before :each do
         @original_seed_title = "This is a unique test title"
         @seed1 = SeedBucket.new(page_title: @original_seed_title); @seed1.save
         @bucket1 = SeedBucket.new; @bucket1.save
         @bucket2 = SeedBucket.new; @bucket2.save
      end
      it "properly copies a seed to a new bucket" do         
         #Innitial conditions tests

         Containment.where(bucket_id: @bucket1.id).empty?.should be true   #destination bucket is empty
         SeedBucket.where(page_title: "This is a unique test title").length.should be 1   #the original seed is uniquely named

         #Test type validations
         lambda{ SeedBucket.copy_seed(nil, @bucket1)}.should raise_error
         lambda{ SeedBucket.copy_seed(@seed1, nil) }.should raise_error

         #Function test         
         lambda{ SeedBucket.copy_seed(@seed1, @bucket1) }.should_not raise_error

         #Post Conditions 
         Containment.where(bucket_id: @bucket1).length.should be 1   #destination bucket now has one seed
         SeedBucket.where(page_title: "This is a unique test title").length.should == 2   #there are now 2 seeds with the original title
         @seed2 = SeedBucket.where(page_title: "This is a unique test title").first                                                                                                                                                                                                                                                
         @seed1.page_title.should == @seed2.page_title
         @seed1.should_not be @seed2  #Copy shouldn't just move the old seed, it should make a new one
         @seed1.page_title.should == @seed2.page_title 
      end
      it "accepts optional parameters to indicate forward_all and in_bucket" do
      end
   end
end
