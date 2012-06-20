class FixQuestionMark < ActiveRecord::Migration
  def change_table :containment do |t|
    t.rename :in?, :in
  end
end
