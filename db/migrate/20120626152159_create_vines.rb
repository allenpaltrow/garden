class CreateVines < ActiveRecord::Migration
  def change
    create_table :vines do |t|
      t.boolean :all
      t.integer :puller_id
      t.integer :pusher_id
      t.timestamps
    end
  end
end
