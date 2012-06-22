class PlantsSeedsUsers < ActiveRecord::Migration
  def change
    drop_table :plants
    
    create_table :plants do |t|
      t.string :title
      t.text :body
      t.integer :bucket_id
      
      t.timestamps
    end
  end
end
