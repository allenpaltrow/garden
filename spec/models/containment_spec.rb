require 'spec_helper'

describe Containment do
  before :each do
    @seed = SeedBucket.new; @seed.save
    @bucket = SeedBucket.new; @bucket.save
  end
  def number_of_containments_between(seed, bucket)
    return Containment.where(bucket_id: bucket.id, seed_id: seed.id).length
  end
  it "only creates one containment when setting .bucket" do
    @seed.bucket = @bucket
    number_of_containments_between(@seed, @bucket).should be 1
  end
  it "only creates one containment for recriprocal bucket/seed pairing and raises error" do
    @seed.bucket = @bucket
    lambda {@bucket.seeds << @seed}.should raise_error
    number_of_containments_between(@seed, @bucket).should be 1
  end
  it "only one containment is made when a seed is put in a bucket several times" do
    @seed.bucket = @bucket
    lambda { 
    @bucket.seeds << @seed
    @bucket.seeds << @seed
    @bucket.seeds << @seed
    }.should raise_error
    number_of_containments_between(@seed, @bucket).should be 1
  end
  it "removes containment when seed is deleted" do
    @seed.bucket = @bucket
    number_of_containments_between(@seed, @bucket).should be 1
    SeedBucket.destroy(@seed)
    number_of_containments_between(@seed, @bucket).should be 0
  end
end