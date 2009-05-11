class CreateQueueItems < ActiveRecord::Migration
  def self.up
    create_table :queue_items do |t|
      t.string :queue_type
      t.string :content

      t.timestamps
    end
    add_index :queue_items, ["queue_type"]
  end

  def self.down
    drop_table :queue_items
  end
end
