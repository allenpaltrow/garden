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
   describe "#copy_one_seed" do
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
         lambda{ SeedBucket.copy_one_seed(nil, @bucket1)}.should raise_error
         lambda{ SeedBucket.copy_one_seed(@seed1, nil) }.should raise_error

         #Function test         
         lambda{ SeedBucket.copy_one_seed(@seed1, @bucket1) }.should_not raise_error

         #Post Conditions 
         Containment.where(bucket_id: @bucket1).length.should be 1   #destination bucket now has one seed
         SeedBucket.where(page_title: "This is a unique test title").length.should == 2   #there are now 2 seeds with the original title
         
         @seed2 = @bucket1.seeds.first                   
                                                                                                                                                                                                                                     
         @seed1.page_title.should == @seed2.page_title
         @seed1.should_not be @seed2  #Copy shouldn't just move the old seed, it should make a new one
         @seed1.page_title.should == @seed2.page_title 
         
         #Vines
<<<<<<< HEAD
         Vine.where(pusher_id: @seed1.id, puller_id: @seed2.id)
         Vine.where(pusher_id: @seed2.id, puller_id: @seed1.id)
         
=======
         Vine.where(pusher_id: @seed1, puller_id: @seed2).length.should == 1
         Vine.where(pusher_id: @seed2, puller_id: @seed1).length.should == 1
>>>>>>> after_new_seed_in_bucket_functionality
         
      end
      it "accepts optional parameters to indicate forward_all and in_bucket" do
      end
   end
   describe "#recursive_seed_Copy" do
      before :each do
         @original_seed_title = "This is a unique test title"
         @original_nested_seed_title = "This is a unique nested test title"
         
         @seed1 = SeedBucket.new(page_title: @original_seed_title); @seed1.save
         @nested_seed_original = SeedBucket.new(page_title: @original_nested_seed_title); @nested_seed_original.save
         
         @bucket1 = SeedBucket.new; @bucket1.save
         @bucket2 = SeedBucket.new; @bucket2.save
      end
      it "properly copies a nested seed to a new bucket" do     
         
         @nested_seed_original.bucket = @seed1
             
         #Innitial conditions tests
         Containment.where(bucket_id: @bucket1.id).empty?.should be true   #destination bucket is empty
         SeedBucket.where(page_title: "This is a unique nested test title").length.should be 1   #the original seed is uniquely named

         #Test type validations
         lambda{ SeedBucket.recursive_copy_seed(nil, @bucket1)}.should raise_error
         lambda{ SeedBucket.recursive_copy_seed(@seed1, nil) }.should raise_error

         #Function test         
         lambda{ SeedBucket.recursive_copy_seed(@seed1, @bucket1) }.should_not raise_error

         #Post Conditions 
         Containment.where(bucket_id: @seed1).length.should be 1   #destination bucket now has one seed
         SeedBucket.where(page_title: "This is a unique nested test title").length.should == 2   #there are now 2 seeds with the original title
         @nested_seed_copy = SeedBucket.where(page_title: "This is a unique nested test title").first                                                                                                                                                                                                                                                

         @nested_seed_original.page_title.should == @nested_seed_copy.page_title
         @nested_seed_original.should_not be @nested_seed_copy  #Copy shouldn't just move the old seed, it should make a new one
      end
   end
end
