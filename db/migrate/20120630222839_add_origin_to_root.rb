class AddOriginToRoot < ActiveRecord::Migration
   change_table :roots do |t|
      t.integer :origin
   end
end
