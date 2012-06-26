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
    it "should be able to set .bucket" do
      sb = SeedBucket.new :bucket=> @bucket
      sb.bucket.should be @bucket
    end
  end
  describe ".bucket" do
    it "should have a null .bucket by default" do
      @seed.bucket.should be nil
    end
    it "should be possible to set SB.bucket " do
      @seed.bucket = @bucket
      @seed.bucket.should be @bucket
    end
    it "should replace the old one if you set it a second time" do

      @seed.bucket = @bucket
      @seed.bucket.should be @bucket

      @seed.bucket = @bucket2 # switch buckets
      @seed.bucket.should be @bucket2
    end
  end

  #######SeedBucket.seeds tests############

  describe "#seeds" do
    it "is empty by default" do
      @bucket.seeds.empty?.should be true 
    end
    it "works to add one seed" do
      @bucket.seeds << @seed
      @bucket.seeds.should include(@seed)
    end

    it "works to add 100 seeds" do
      seedArray = []
      for i in 1..100
        seed_temp = SeedBucket.new
        seedArray << seed_temp
        @bucket.seeds << seed_temp
      end
      seedArray.each {|iterated_seed| @bucket.seeds.should include(iterated_seed)}
    end

    it "is only possible to add a particular seed to a particular bucket once" do
      lambda{
        @bucket.seeds << @seed
        @bucket.seeds << @seed
        @bucket.seeds << @seed
      }.should raise_error
      @bucket.seeds.should == @bucket.seeds.uniq
    end
  end
  ######Seed and Bucket Integration tests #############
  describe "Seed and Bucket intregration" do 
    it "should be reciprocal to set .bucket and add to .seed" do
      @seed.bucket = @bucket
      @bucket.seeds.should include @seed
    end

    it "should set .bucket when seed is added" do
      @bucket.seeds << @seed
      @seed.bucket.should == @bucket
    end
  end
  ########### Deleting Nodes ###########################
  describe "deleting nodes" do 
    it "should be that Deleting a seed removes it from the bucket it was in" do
      @bucket.seeds << @seed
      @bucket.seeds.should include @seed
      SeedBucket.destroy(@seed)
      SeedBucket.find(@bucket).seeds.should_not include @seed
    end
  end
end
