class StartController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  EMAIL_VALIDATION_RE = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)$/i

  before_filter :login_required, :only => [:email_invites]
  
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
      uniqs = []
      uhash = {}
      items.each do |item|
        last = item.last_reply
        if uhash[last].blank?
          uhash[last] = true
          uniqs << item
        end
      end
      items = uniqs.sort_by{|i| i.last_activity_time}.reverse

      @notifications = items[0..6]
    end
  end

  def test
   render :layout => false
  end

  def email_invites
    @topic = Topic.find params[:id]
    @to_field = params[:emails]
    @emails = []
    @entries = []
    @broken_entries= []
    @to_field.strip.split(',').each do |entry|
      entry.strip!
      if entry.starts_with? '@'
        to_user = User.find_by_login(entry[1..-1])
        if to_user.blank?
          @broken_entries << [entry, "no such user"]
        else
          to_email = to_user.email
          if to_email =~ EMAIL_VALIDATION_RE
            @emails << to_email
            @entries << entry
          else
            @broken_entries << [entry, "user does not have a valid email on file"]
          end
        end
      elsif entry =~ EMAIL_VALIDATION_RE
        @emails << entry
        @entries << entry
      else
        @broken_entries << [entry, "not a valid email address"]
      end
    end
    @emailContent = params[:content]
    @emailContent += "\r\n\r\nthis message was sent by the user #{current_user.login} on JabberAt.com (#{url_for(:controller => :users, :action => :show, :id => current_user, :only_path => false)})"
    UserMailer.deliver_invite(current_user,@emails.join(","),@emailContent) if @emails.size > 0
    respond_to do |format|
      flash[:notice] = @to_field.blank? ? 'No one to send invitation to.' : ''
      flash[:notice] += "Invites successfully emailed to #{@entries.join(",")}. <br/>" if @entries.size > 0
      if @broken_entries.size > 0
        flash[:notice] += "<br/>Could not send email to the following:<br/>"
        @broken_entries.each do |be|
          flash[:notice] += "  #{be.first} : #{be.last} <br/>"
        end
      end
      flash[:notice] += "<br/><a href=\"#\" onclick=\"$('ajax_notifier').hide();return false;\">OK</a>"
      format.js
    end
  end
  
end
