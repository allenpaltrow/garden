class SeedBucketsController < ApplicationController
  def index
    @SeedBuckets = SeedBucket.all
  end
  def bucket_view
    @bucket = SeedBucket.find(params[:seed_bucket_id])
  end
  def seed_view
    @seed = SeedBucket.find(params[:seed_bucket_id])
  end
  def new_bucket
  end
  def new_seed
  end
end
