class AddUsersVines < ActiveRecord::Migration
  def change
    change_table :plants do |t|
      t.integer :user_id
      t.integer :vine_id
    end
  end
end
