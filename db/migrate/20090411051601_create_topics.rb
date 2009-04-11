class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :content, :length => 1024
      t.integer :user_id
      t.string :image_url

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
