class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :content, :limit => 1024
      t.integer :user_id
      t.integer :topic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
