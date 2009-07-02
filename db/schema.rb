# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090702005918) do

  create_table "comments", :force => true do |t|
    t.string   "content",    :limit => 512
    t.integer  "user_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "level"
  end

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                   :null => false
    t.string   "followable_type", :default => "", :null => false
    t.integer  "follower_id",                     :null => false
    t.string   "follower_type",   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "queue_items", :force => true do |t|
    t.string   "queue_type"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "queue_items", ["queue_type"], :name => "index_queue_items_on_queue_type"

  create_table "topics", :force => true do |t|
    t.string   "content",    :limit => 512
    t.integer  "user_id"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", :force => true do |t|
    t.string   "cookie"
    t.integer  "user_id"
    t.string   "path"
    t.string   "parameters", :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["cookie"], :name => "index_tracks_on_cookie"
  add_index "tracks", ["created_at"], :name => "index_tracks_on_created_at"
  add_index "tracks", ["user_id"], :name => "index_tracks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "avatar_url"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.boolean  "subscribe"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
