class RemoveInFromSb < ActiveRecord::Migration
  change_table :seed_buckets do |t|
    t.remove :in  # in shouldn't be on the seedbucket table, it should be in the containment table
  end
end
