class AddBucketSlugs < ActiveRecord::Migration
   def up
      change_table :seed_buckets do |t|
         t.string :slug
      end

      add_index :seed_buckets, :slug
   end
end
