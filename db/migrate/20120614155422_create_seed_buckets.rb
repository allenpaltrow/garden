class CreateSeedBuckets < ActiveRecord::Migration
  def change
    create_table :seed_buckets do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
    
  end
end
