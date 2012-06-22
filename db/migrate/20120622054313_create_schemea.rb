class CreateSchemea < ActiveRecord::Migration
  def change
    create_table :seeds do |t|
      t.string :title
      t.text :body
      t.integer :vine_id
      t.integer :user_id
      
      t.timestamps
    end
    
    create_table :vines do |t|
      t.timestamps
    end
    
    create_table :users do |t|
      t.string :name
      t.string :email
      
      t.timestamps
    end
    
    drop_table :seed_buckets
    
    drop_table :containments
  
  end
end
