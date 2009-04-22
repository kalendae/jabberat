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

end
