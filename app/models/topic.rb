class Topic < ActiveRecord::Base
  acts_as_ferret :fields => [:content]
  has_many :comments
  belongs_to :user

  def last_activity_time
    updated_at
  end

  def last_comment
    comments.inject do |memo,comment|
      memo.created_at > comment.created_at ? memo : comment
    end
  end

  def last_reply
    last_comment
  end

  def topic
    self
  end

  def all_users_before_comment comment
    user_hash = {}
    comments.each do |c|
      if c.created_at < comment.created_at
        if user_hash[c.user].blank?
          user_hash[c.user] = true
        end
      end
    end
    if user_hash[self.user].blank?
      user_hash[self.user] = true
    end
    user_hash.keys
  end

end
