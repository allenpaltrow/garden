require 'spec_helper'

describe SeedBucket do
   before :each do
      @seed = SeedBucket.new; @seed.save
      @bucket = SeedBucket.new; @bucket.save
      @bucket2 = SeedBucket.new; @bucket.save
   end
   describe "#new" do
      it "returns a SeedBucket object" do
         @seed.should be_an_instance_of SeedBucket
      end
   end
end
