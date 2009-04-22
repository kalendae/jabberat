class StartController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  def index
    @topic = Topic.new
    @comment = Comment.new
    @hot_topics = Topic.find(:all, :order => "updated_at DESC", :limit => 6)
    if not params[:t].blank?
      @query = params[:t].split(' ').collect{|term| term + '~'}.join(' OR ')
      @topics = Topic.find_with_ferret(@query, :limit => 5)
      @content = params[:t]
      if @topics.blank? and @content.length > 15
        redirect_post(:controller => 'topics', :action => 'create', :topic => {:content => @content})
      end
    elsif not params[:id].blank?
      @topic = Topic.find params[:id]
      @root_comments = @topic.comments.find_all_by_parent_id(nil).sort_by{|c| c.created_at}
      @root_comments = @root_comments.reverse
      @comments = []
      @root_comments.each do |root_comment|
        @comments += root_comment.with_children_in_order
      end
    end

    # recent activities
    if current_user
      items = current_user.comments.select{|c| !c.last_reply.nil? and c.last_reply.user != current_user}
      items += current_user.topics.select{|t| !t.last_comment.nil? and t.last_comment.user != current_user}
      items = items.sort_by{|i| i.last_activity_time}.reverse
      @notifications = items[0..6]
    end
  end

  def test
   render :layout => false
  end
  
end
