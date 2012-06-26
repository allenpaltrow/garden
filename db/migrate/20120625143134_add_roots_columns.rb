class AddRootsColumns2 < ActiveRecord::Migration
   change_table :roots do |t|
      t.integer :parent_id
      t.integer :child_id
   end
end
