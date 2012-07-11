class SeedBucketsController < ApplicationController
def index
   @SeedBuckets = SeedBucket.all
end
def show
   @seedbucket = SeedBucket.find(params[:seed_bucket_id])
   if request.path != seed_bucket_path(@seedbucket)
      redirect_to @article, status: :moved_permanently
   end
      if params[:page_type] == "seed"
         render :action => 'seed_view'
      elsif params [:page_type] == "bucket" 
         render :action => 'bucket_view'
      else
         throw "Pages can only be viewed as seeds or buckets"
      end
   end
   def new_bucket
   end
   def new_seed
   end
end
