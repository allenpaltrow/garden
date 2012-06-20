class CreateContainments < ActiveRecord::Migration
  def change
    create_table :containments do |t|
      
      t.integer :bucket_id
      t.integer :seed_id
      
      t.integer :order
      t.boolean :in?
      t.timestamps
      
    end
  end
end
