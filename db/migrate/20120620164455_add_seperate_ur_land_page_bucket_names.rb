class AddSeperateUrLandPageBucketNames < ActiveRecord::Migration
  def up
    change_table :seed_buckets do |t|
      t.rename :title, :page_title
      t.string :url_title
    end
  end

  def down
    change_table :seed_buckets do |t|
      t.rename :page_title, :title
      t.remove :url_title
    end
  end
end
