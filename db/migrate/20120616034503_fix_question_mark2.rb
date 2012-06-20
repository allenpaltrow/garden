class FixQuestionMark2 < ActiveRecord::Migration
  change_table :containments do |t|
    t.rename :in?, :in # "?" isn't allowed in SQL table
  end
end
