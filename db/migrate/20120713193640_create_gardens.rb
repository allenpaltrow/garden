class CreateGardens < ActiveRecord::Migration
  def change
    create_table :gardens do |t|

      t.timestamps
    end
  end
end
