class Comment < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  belongs_to :parent, :class_name => 'Comment', :foreign_key => :parent_id
  has_many :children, :class_name => 'Comment', :foreign_key => :parent_id

  def with_children_in_order
    r = [self]
    self.children.reverse.each do |child|
      r += child.with_children_in_order
    end
    r
  end

  def last_activity_time
    last_reply = self.with_children_in_order.inject do |memo,comment|
      memo.created_at > comment.created_at ? memo : comment
    end
    last_reply.created_at
  end

  def last_reply
    last_reply = self.with_children_in_order.inject do |memo,comment|
      memo.created_at > comment.created_at ? memo : comment
    end
  end

  def parent_by_user(user)
    p = parent
    while p != nil and p.user != user
      p = p.parent
    end
    p
  end

  def find_all_past_users_in_topic
    users = topic.all_users_before_comment self
    users.delete user
    users
  end

  def notify_all_past_users_in_topic
    UserMailer.deliver_notify(user,find_all_past_users_in_topic,topic,self)
  end

end
