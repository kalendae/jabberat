class AddSubscribeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribe, :boolean
  end

  def self.down
    remove_column :users, :subscribe
  end
end
