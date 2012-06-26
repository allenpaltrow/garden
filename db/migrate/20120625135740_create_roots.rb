class CreateRoots < ActiveRecord::Migration
   def change
      create_table :roots do |t|

         t.timestamps
      end
   end
end
