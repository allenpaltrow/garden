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
         @seed1 = SeedBucket.create(page_title: @original_seed_title)
         @seed2 = SeedBucket.create(page_title: "second seed")
         @bucket1 = SeedBucket.create
         @bucket2 = SeedBucket.create
      end
      it "properly copies @seed1 from @bucket1 to @bucket2" do         
         ## Configuration ##
         lambda{@seed1.bucket = @bucket1}.should_not raise_error

         #Innitial conditions tests
         @bucket1.seeds.length.should be 1
         Containment.where(bucket_id: @bucket1.id).length.should be 1  
         @bucket1.seeds.first.should == @seed1
         @bucket1.seeds.first.page_title.should == "This is a unique test title"

         @bucket2.seeds.empty?.should be true
         Containment.where(bucket_id: @bucket2.id).empty?.should be true   #destination bucket is empty
         SeedBucket.where(page_title: "This is a unique test title").length.should be 1   #the original seed is uniquely named

         ## Vines
         Vine.where(pusher_id: @seed1).length.should == 0
         Vine.where(puller_id: @seed1).length.should == 0

         ## Test type validations
         lambda{ SeedBucket.copy_one_seed(nil, @bucket1)}.should raise_error
         lambda{ SeedBucket.copy_one_seed(@seed1, nil) }.should raise_error

         ## Function test         
         lambda{ SeedBucket.copy_one_seed(@seed1, @bucket2) }.should_not raise_error

         ## Post Conditions P1 = things that should not be changed aren't  (accept the things you cannot change – serenity)
         @bucket1.seeds.length.should be 1
         Containment.where(bucket_id: @bucket1.id).length.should be 1  
         @bucket1.seeds.first.should == @seed1
         @bucket1.seeds.first.page_title.should == "This is a unique test title"

         ## Post conditions P2 = desired changes are preformed (change the things you can – courage)
         @bucket2.seeds.empty?.should be false
         Containment.where(bucket_id: @bucket2.id).empty?.should be false   #destination bucket is empty
         SeedBucket.where(page_title: "This is a unique test title").length.should be 2   #the original seed is uniquely named

         @copied_seed = @bucket2.seeds.first
         @bucket2.seeds.length.should be 1
         @copied_seed.nil?.should be false
         @copied_seed.page_title.should == "This is a unique test title"

         @seed1.page_title.should == @copied_seed.page_title
         @seed1.should_not be @copied_seed  #Copy shouldn't just move the old seed, it should make a new one
         @seed1.page_title.should == @copied_seed.page_title 

         @copied_seed.created_at.should be > @seed1.created_at 

         ## Vines
         Vine.where(pusher_id: @seed1.id, puller_id: @copied_seed.id).length.should be 1
         Vine.where(pusher_id: @copied_seed.id, puller_id: @seed1.id).length.should be 1
         @seed1.pushes_to.should include @copied_seed
         @copied_seed.pushes_to.should include @seed1
         @seed1.pulls_from.should include @copied_seed
         @copied_seed.pulls_from.should include @seed1

         ## Roots
         Root.where(parent_id: @seed1, child_id: @copied_seed).length.should be 1
         Root.where(parent_id: @copied_seed, child_id: @seed1).length.should be 0
         @seed1.children.length.should be 1
         @seed1.children.first.should == @copied_seed
         @seed1.parent.should_not be @copied_seed

         @copied_seed.children.length.should be 0
         @copied_seed.parent.nil?.should be false
         @copied_seed.parent.should == @seed1 

         Root.where(parent_id: @seed1.id).length.should be 1
         Root.where(parent_id: @copied_seed.id).length.should be 0
         Root.where(child_id: @copied_seed.id).length.should be 1
         Root.where(child_id: @seed1.id).length.should be 0

         ## Containment
         Containment.where(bucket_id: @bucket2.id, seed_id: @copied_seed).length.should be 1
         Containment.where(bucket_id: @copied_seed.id, seed_id: @bucket2).length.should be 0
         Containment.where(bucket_id: @bucket2.id, seed_id: @seed1).length.should be 0

      end
      it "accepts optional parameters" do
         @bucket2.seeds.empty?.should be true
         lambda{ SeedBucket.copy_one_seed(@seed1, @bucket2, {put_in_bucket: true, old_seed_forwards_all: true})}.should_not raise_error
         lambda{ SeedBucket.copy_one_seed(@seed2, @bucket2, {put_in_bucket: false, new_seed_forwards_all: true})}.should_not raise_error

         @bucket2.seeds.length.should be 2

         @seed1_copy = @seed1.children.first         
         @seed1_copy.should_not be nil 
         @seed1_copy.page_title.should == @seed1.page_title
         
         @seed2_copy = @seed2.children.first
         @seed2_copy.should_not be nil
         @seed2_copy.page_title.should == @seed2.page_title
         
         Containment.where(seed_id: @seed1_copy.id).first.in_bucket.should be true
         Vine.where(pusher_id: @seed1.id).first.forwards_all.should be true
         Vine.where(pusher_id: @seed1_copy.id).first.forwards_all.should be false
         
         Containment.where(seed_id: @seed2_copy.id).first.in_bucket.should be false
         Vine.where(pusher_id: @seed2.id).first.forwards_all.should be false
         Vine.where(pusher_id: @seed2_copy.id).first.forwards_all.should be true
      end
      it "knows whether derivative seed is already in bucket" do
         SeedBucket.copy_one_seed(@seed1, @bucket1)
         @seed2.bucket = @bucket2
         @seed1.is_already_in(@bucket1).should be true
         @seed1.is_already_in(@bucket2).should be false         
      end
   end
   describe "#recursive_seed_Copy" do
      before :each do
         @original_seed_title = "This is a unique test title"
         @original_nested_seed_title = "This is a unique nested test title"

         @seed1 = SeedBucket.create(page_title: @original_seed_title)
         @nested_seed_original = SeedBucket.create(page_title: @original_nested_seed_title)

         @bucket1 = SeedBucket.create
         @bucket2 = SeedBucket.create

         ## Configuration ##
         @nested_seed_original.bucket = @seed1
         @seed1.bucket = @bucket1
      end
      it "properly copies seed1 and nested_seed_original from bucket1 to bucket2 " do     

         #Innitial conditions tests

         ## Bucket1 <- Seed1
         @bucket1.seeds.length.should be 1
         Containment.where(bucket_id: @bucket1.id).length.should be 1  
         @bucket1.seeds.first.should == @seed1
         @bucket1.seeds.first.page_title.should == "This is a unique test title"
         SeedBucket.where(page_title: "This is a unique test title").length.should be 1   #the original seed is uniquely named

         ## Seed1 <- nested_seed_original
         @seed1.seeds.length.should be 1
         Containment.where(bucket_id: @seed1.id).length.should be 1  
         @seed1.seeds.first.should == @nested_seed_original
         @seed1.seeds.first.page_title.should == "This is a unique nested test title"
         SeedBucket.where(page_title: "This is a unique nested test title").length.should be 1   #the nested seed is uniquely named

         ## Bucket2 <- nil
         @bucket2.seeds.empty?.should be true
         Containment.where(bucket_id: @bucket2.id).empty?.should be true   #destination bucket is empty

         ## Test type validations
         lambda{ SeedBucket.copy_one_seed(nil, @bucket1)}.should raise_error
         lambda{ SeedBucket.copy_one_seed(@seed1, nil) }.should raise_error

         ## Function test         
         lambda{ SeedBucket.recursive_copy_seed(@seed1, @bucket2) }.should_not raise_error

         ## Post Conditions P1 = things that should not be changed aren't  (accept the things you cannot change – serenity)
         ## Bucket1 <- Seed1
         @bucket1.seeds.length.should be 1
         Containment.where(bucket_id: @bucket1.id).length.should be 1  
         @bucket1.seeds.first.should == @seed1
         @bucket1.seeds.first.page_title.should == "This is a unique test title"

         ## Seed1 <- nested_seed_original
         @seed1.seeds.length.should be 1
         Containment.where(bucket_id: @seed1.id).length.should be 1  
         @seed1.seeds.first.should == @nested_seed_original
         @seed1.seeds.first.page_title.should == "This is a unique nested test title"       

         ## Post conditions P2 = desired changes are preformed (change the things you can – courage)
         ## bucket2 <- copied_seed
         @bucket2.seeds.empty?.should be false
         Containment.where(bucket_id: @bucket2.id).length.should be 1
         SeedBucket.where(page_title: "This is a unique test title").length.should be 2   #the original seed is uniquely named

         @bucket2.seeds.length.should be 1
         @copied_seed = @bucket2.seeds.first
         @copied_seed.nil?.should be false
         @copied_seed.page_title.should == "This is a unique test title"

         @seed1.page_title.should == @copied_seed.page_title
         @seed1.should_not be @copied_seed  #Copy shouldn't just move the old seed, it should make a new one

         @copied_seed.created_at.should be > @seed1.created_at 

         ## seed2 <- nested_seed
         @copied_seed.seeds.length.should be 1
         Containment.where(bucket_id: @copied_seed.id).length.should be 1   #destination bucket is empty
         SeedBucket.where(page_title: "This is a unique nested test title").length.should be 2   #the original seed is uniquely named

         @copied_seed.seeds.length.should be 1
         @nested_seed_new = @copied_seed.seeds.first
         @nested_seed_new.nil?.should be false
         @nested_seed_new.page_title.should == "This is a unique nested test title"

         @nested_seed_original.page_title.should == @nested_seed_new.page_title
         @nested_seed_original.should_not be @nested_seed_new  #Copy shouldn't just move the old seed, it should make a new one

         @nested_seed_original.created_at.should be < @nested_seed_new.created_at

         ## Vines
         Vine.where(pusher_id: @nested_seed_original.id, puller_id: @nested_seed_new.id).length.should be 1
         Vine.where(pusher_id: @nested_seed_new.id, puller_id: @nested_seed_original.id).length.should be 1

         @nested_seed_original.pushes_to.should include @nested_seed_new
         @nested_seed_new.pushes_to.should include @nested_seed_original
         @nested_seed_original.pulls_from.should include @nested_seed_new
         @nested_seed_new.pulls_from.should include @nested_seed_original

         ## Roots
         Root.where(parent_id: @nested_seed_original, child_id: @nested_seed_new).length.should be 1
         Root.where(parent_id: @nested_seed_new, child_id: @nested_seed_original).length.should be 0
         @nested_seed_original.children.length.should be 1
         @nested_seed_original.children.first.should == @nested_seed_new
         @nested_seed_original.parent.should_not be @nested_seed_new

         @nested_seed_new.children.length.should be 0
         @nested_seed_new.parent.nil?.should be false
         @nested_seed_new.parent.should == @nested_seed_original

         Root.where(parent_id: @nested_seed_original.id).length.should be 1
         Root.where(parent_id: @nested_seed_new.id).length.should be 0
         Root.where(child_id: @nested_seed_new.id).length.should be 1
         Root.where(child_id: @nested_seed_original.id).length.should be 0

         ## Containment
         Containment.where(bucket_id: @copied_seed.id, seed_id: @nested_seed_new).length.should be 1
         Containment.where(bucket_id: @nested_seed_new.id, seed_id: @copied_seed).length.should be 0
         Containment.where(bucket_id: @copied_seed.id, seed_id: @nested_seed_original).length.should be 0
      end
   end
end
