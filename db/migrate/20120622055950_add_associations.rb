class AddAssociations < ActiveRecord::Migration
  def change
    create_table :plants do |t|
      t.integer :bucket_id
      t.integer :seed_id
      
      t.timestamps
    end
  end
end
