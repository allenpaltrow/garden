class AddAccepts < ActiveRecord::Migration
   change_table :vines do |t|
     t.boolean :accepts
   end
end
