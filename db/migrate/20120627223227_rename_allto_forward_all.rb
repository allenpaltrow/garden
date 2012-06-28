class RenameAlltoForwardAll < ActiveRecord::Migration
   change_table :vines do |t|
     t.rename :all, :forward_all
   end
end
