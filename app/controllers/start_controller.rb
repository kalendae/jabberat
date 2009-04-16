class StartController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  def index
    @topic = Topic.new
    @comment = Comment.new
    @hot_topics = Topic.find(:all, :order => "updated_at DESC", :limit => 10)
    if not params[:t].blank?
      @query = params[:t].split(' ').collect{|term| term + '~'}.join(' OR ')
      @topics = Topic.find_with_ferret(@query, :limit => 5)
      @content = params[:t]
      if @topics.blank?
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
  end

end
