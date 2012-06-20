require 'test_helper'

class ContainmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Putting seed in a bucket creates one containment" do
    seed = SeedBucket.new; seed.save
    bucket = SeedBucket.new; bucket.save
    seed.bucket = bucket
    assert_equal Containment.where(bucket_id: bucket.id, seed_id: seed.id).length, 1
    seed = nil
    bucket = nil
  end

  test "S->B, B<-S only makes 1 containment" do
    seed = SeedBucket.new; seed.save
    bucket = SeedBucket.new; bucket.save
    seed.bucket = bucket
    bucket.seeds << seed
    number_of_containments_between_seed_and_bucket = Containment.where(bucket_id: bucket.id, seed_id: seed.id).length
    assert_equal number_of_containments_between_seed_and_bucket, 1
    seed = nil
    bucket = nil
  end

  test "Putting a seed in a bucket several times only makes 1 containment" do
    seed = SeedBucket.new; seed.save
    bucket = SeedBucket.new; bucket.save
    seed.bucket = bucket

    bucket.seeds << seed
    bucket.seeds << seed
    bucket.seeds << seed
    
    assert_equal Containment.where(bucket_id: bucket.id, seed_id: seed.id).length, 1, "Adding a seed to a bucket several times made several identical containments"
    seed = nil
    bucket = nil
  end

  test "Deleting a seed removes its 1 containment" do
    seed = SeedBucket.new; seed.save
    bucket = SeedBucket.new; bucket.save
    seed.bucket = bucket
    assert_equal Containment.where(bucket_id: bucket.id, seed_id: seed.id).length, 1
    SeedBucket.destroy(seed)
    assert_equal Containment.where(bucket_id: bucket.id, seed_id: seed.id).length, 0
    seed = nil
    bucket = nil
  end
end
