class MoveOrigintoSeedBucket < ActiveRecord::Migration
   change_table :roots do |t|
      t.remove :origin
   end
   change_table :seed_buckets do |t|
     t.integer :origin_id
   end
end
