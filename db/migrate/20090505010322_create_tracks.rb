class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :cookie
      t.integer :user_id
      t.string :path
      t.string :parameters, :limit => 1024
      t.timestamps
    end
    add_index :tracks, [:cookie]
    add_index :tracks, [:user_id]
    add_index :tracks, [:created_at]
  end

  def self.down
    drop_table :tracks
  end
end
