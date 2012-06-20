require 'test_helper'

class SeedBucketTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end


  ###SeedBucket.bucket tests########## SB is short for SeedBucket

  test "SeedBucket has null bucket by default" do
    sb = SeedBucket.new
    assert_nil sb.bucket, "SeedBucket.bucket is not nil by defailt"
    sb = nil
  end

  test "SB.bucket can be set" do
    sb1 = SeedBucket.new
    sb2 = SeedBucket.new
    sb1.bucket = sb2
    assert_equal sb1.bucket, sb2, "SB.bucket wasn't set successfully"
    sb1 = nil
    sb2 = nil
  end
  test "Setting .bucket a second time replaces old bucket" do
    bucket1 = SeedBucket.new
    bucket2 = SeedBucket.new
    seed = SeedBucket.new
    seed.bucket = bucket1
    assert_equal seed.bucket, bucket1, "Failure to set .bucket"

    seed.bucket = bucket2 # switch buckets
    assert_equal seed.bucket, bucket2, "Failure to replace first SB.bucket with second"

    seed = nil
    bucket1 = nil
    bucket2 = nil
  end

  #######SeedBucket.seeds tests############

  test "SB.seeds is empty by default" do
    bucket = SeedBucket.new
    assert bucket.seeds.empty?
    bucket = nil
  end

  test "Adding one seed works" do
    bucket = SeedBucket.new
    seed = SeedBucket.new
    bucket.seeds << seed
    assert bucket.seeds.include?(seed)
    bucket = nil
    seed = nil
  end

  test "Adding 1000 seeds works" do
    bucket = SeedBucket.new
    seedArray = []
    for i in 1..1000
      seed_temp = SeedBucket.new
      seedArray << seed_temp
      bucket.seeds << seed_temp
    end

    seedArray.each {|iterated_seed| assert bucket.seeds.include?(iterated_seed)}
    bucket = nil
    seedArray = nil
  end

  test "Can only add a particular seed to a particular bucket once" do
    bucket = SeedBucket.new
    seed = SeedBucket.new

    bucket.seeds << seed
    bucket.seeds << seed
    bucket.seeds << seed

    assert_equal bucket.seeds, bucket.seeds.uniq, "Seed added to bucket multiple times"
  end
  
  ######Seed and Bucket Integration tests #############

  test "Setting .bucket is reciprocal to adding .seed" do
    bucket = SeedBucket.new; bucket.save
    seed = SeedBucket.new; seed.save
    seed.bucket = bucket
    assert bucket.seeds.include?(seed)
    bucket = nil
    seed = nil
  end

  test "Adding seed is reciprocal to setting .bucket" do
    bucket = SeedBucket.new; bucket.save
    seed = SeedBucket.new; seed.save
    bucket.seeds << seed
    assert_equal seed.bucket, bucket
  end
  
  ########### Deleting Nodes ###########################
  
  test "Deleting a seed removes it from the bucket" do
    bucket = SeedBucket.new; bucket.save
    seed = SeedBucket.new; seed.save
    bucket.seeds << seed
    assert bucket.seeds.include?(seed)
    SeedBucket.destroy(seed)
    assert !bucket.seeds.include?(seed)
  end
  
end