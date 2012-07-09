require 'spec_helper'

describe Vine do
   before :each do
      @seed1 = SeedBucket.create
      @bucket1 = SeedBucket.create
      @bucket2 = SeedBucket.create
      @bucket3 = SeedBucket.create
      @bucket4 = SeedBucket.create
   end
   def number_of_vines_between(seed, bucket)
      return Vine.where(pusher_id: @bucket1.id, puller_id: @bucket2.id).length + 
             Vine.where(pusher_id: @bucket2.id, puller_id: @bucket1.id).length
   end
  
   #######  SeedBucket.pushes_to tests  ############

   describe ".pushes_to array" do
      it "is empty by default" do
         @bucket1.pushes_to.empty?.should be true 
      end
      it "should let you add to .pushes_to array" do
         @bucket1.pushes_to << @bucket2
         @bucket1.pushes_to.should include(@bucket2)
      end

      it "lets you add many buckets to .pushes_to array" do
         pushesArray = []
         for i in 1..100
            bucket_temp = SeedBucket.new
            pushesArray << bucket_temp
            @bucket1.pushes_to << bucket_temp
         end
         pushesArray.each {|iterated_bucket| @bucket1.pushes_to.should include(iterated_bucket)}
      end

      it "only lets you create a particular type of vine between two particular buckets once" do
         lambda{ 3.times { @bucket1.pushes_to << @bucket2 } }.should raise_error
         @bucket1.pushes_to.should == @bucket1.pushes_to.uniq
      end
   end
   
   #######  SeedBucket.pulls_from tests  ############

   describe ".pulls_from" do
      it "is empty by default" do
         @bucket1.pulls_from.empty?.should be true 
      end
      it "works to add one bucket" do
         @bucket1.pulls_from << @bucket2
         @bucket1.pulls_from.should include(@bucket2)
      end

      it "lets you add many buckets to .pulls_from array" do
         pullsArray = []
         for i in 1..100
            bucket_temp = SeedBucket.new
            pullsArray << bucket_temp
            @bucket1.pulls_from << bucket_temp
         end
         pullsArray.each {|iterated_bucket| @bucket1.pulls_from.should include(iterated_bucket)}
      end

      it "only lets you create a particular type of vine between two particular buckets once" do
         lambda{ 3.times{ @bucket1.pulls_from << @bucket2 } }.should raise_error
         @bucket1.pulls_from.should == @bucket1.pulls_from.uniq
      end
   end
   
   #######  Push / Pull Integration Tests  #############
   
   describe ".Seed and .Bucket intregration" do 
      it "should be reciprocal to set .pulls_from and to .pushes_to" do
         @bucket1.pulls_from << @bucket2
         @bucket2.pushes_to.should include @bucket1
         
         @bucket3.pushes_to << @bucket4
         @bucket4.pulls_from.should include @bucket3
      end
   end
   
   ########### Deleting Nodes ###########################
   
   describe "deleting nodes" do 
      it "automatically deletes vines between deleted buckets" do
         @bucket1.pushes_to << @bucket2
         @bucket1.pushes_to.should include @bucket2
         SeedBucket.destroy(@bucket2)
         SeedBucket.find(@bucket1).pushes_to.should_not include @seed
      end
   end
   ########## Push Across vines ########################
   describe "push_across_vines" do
      it "the .push_across_vines function works" do
         @bucket1.pushes_to << @bucket2
         @bucket2.pushes_to << @bucket3
         @bucket2.pushes_to << @bucket4
         @bucket4.pushes_to << @bucket1
         
         @seed1.bucket = @bucket1
         
         @seed1.push_across_vines
#         @seed1.is_already_in(@bucket2).should be true
#         @seed1.is_already_in(@bucket3).should be false
#         @seed1.is_already_in(@bucket4).should be false
#         @bucket1.seeds.length.should be 1
         
         @bucket2.seeds.first.push_across_vines
         @seed1.is_already_in(@bucket2).should be true
         @seed1.is_already_in(@bucket3).should be true
         @seed1.is_already_in(@bucket4).should be true
         @bucket1.seeds.length.should be 1
      end
      it "pushes a seed across all the bucket's vines on_save" do
         ## configure ##
         @bucket1.pushes_to << @bucket2
         @bucket2.pushes_to << @bucket3
         @bucket2.pushes_to << @bucket4
         @bucket4.pushes_to << @bucket1

         @seed1.is_already_in(@bucket2).should be false
         @seed1.is_already_in(@bucket3).should be false
         @seed1.is_already_in(@bucket4).should be false        
         lambda{ @bucket1.seeds << @seed1; @seed1.push_across_vines}.should_not raise_error
         @seed1.is_already_in(@bucket2).should be true
         @seed1.is_already_in(@bucket3).should be true
         @seed1.is_already_in(@bucket4).should be true
         @bucket1.seeds.length.should be 1
      end
      
   end
end
