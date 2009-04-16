class AddParentIdToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :parent_id, :integer
    add_column :comments, :level, :integer
  end

  def self.down
    remove_column :comments, :level
    remove_column :comments, :parent_id
  end
end
