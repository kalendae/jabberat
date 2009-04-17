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

end
