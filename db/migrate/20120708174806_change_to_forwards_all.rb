class ChangeToForwardsAll < ActiveRecord::Migration
   change_table :vines do |t|
     t.rename :forward_all, :forwards_all
   end
end
