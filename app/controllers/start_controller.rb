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
      @comments = @topic.comments.sort_by{|c| c.created_at}
      @comments = @comments.reverse
    end 
  end
end
