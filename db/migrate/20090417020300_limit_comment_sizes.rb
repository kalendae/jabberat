class LimitCommentSizes < ActiveRecord::Migration
  def self.up
    change_column :topics, :content, :string, :limit => 512
    change_column :comments, :content, :string, :limit => 512
  end

  def self.down
    change_column :topics, :content, :string, :limit => 1024
    change_column :comments, :content, :string, :limit => 1024
  end
end
