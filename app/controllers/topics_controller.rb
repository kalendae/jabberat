class TopicsController < ApplicationController

  include AuthenticatedSystem

  before_filter :login_required, :only => [:create, :update]
  
  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])
    @topic.user = current_user
    respond_to do |format|
      if @topic.save
        format.html { redirect_to(:controller => :start, :action => :index, :id => @topic) }
        format.xml  { render :xml => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])

    properly_owned = (current_user == @topic.user)

    flash[:error] = "Must be author of a topic to update it." unless properly_owned

    respond_to do |format|
      if properly_owned and @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to(@topic) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    if super_user?
      @topic = Topic.find(params[:id])
      @topic.destroy
    end

    respond_to do |format|
      format.html { redirect_to(topics_url) }
      format.xml  { head :ok }
    end
  end
end
