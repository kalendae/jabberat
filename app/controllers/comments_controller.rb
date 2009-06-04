class CommentsController < ApplicationController

  before_filter :get_topic
  before_filter :login_required, :only => [:create, :update]

  def get_topic
    @topic = Topic.find params[:topic_id]
  end
  
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @comment.topic = @topic
    @topic.updated_at = Time.now
    @topic.save
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        # a new reply needs to be queued for async stuff like emails out to people
        qi = QueueItem.new(:queue_type => 'new_comment', :content => @comment.id.to_s)
        qi.save
        format.html { redirect_to(:controller => :start, :action => :index, :id => @topic) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    properly_owned = (current_user == @comment.user)

    flash[:error] = "Must be author of a comment to update it." unless properly_owned

    respond_to do |format|
      if properly_owned and @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    if super_user?
      @comment = Comment.find(params[:id])
      @comment.destroy
    end

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
