class ChangeIntoInBucket < ActiveRecord::Migration
   change_table :containments do |t|
     t.rename :in, :in_bucket
   end
end
