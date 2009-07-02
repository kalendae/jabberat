class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required, :only => [:update_avatar_url, :follow, :unfollow, :toggle_subscribe]

  def index
    @users = User.find_all_by_deleted_at(nil)
  end

  def follow
    @user = User.find params[:id]
    current_user.follow(@user)
    flash[:notice] = "You are now following #{@user.login}"
    respond_to do |format|
      format.html {redirect_to(@user)}  
    end
  end

  def unfollow
    @user = User.find params[:id]
    current_user.stop_following(@user)
    flash[:notice] = "You have stopped following #{@user.login}"
    respond_to do |format|
      format.html {redirect_to(@user)}  
    end
  end

  def toggle_subscribe
    if current_user.subscribe
      flash[:notice] = "You have unscribed to the weekly update."
      current_user.subscribe = false
    else
      flash[:notice] = 'You have subscribed to the weekly update.'
      current_user.subscribe = true
    end
    current_user.save!
    respond_to do |format|
      format.html {redirect_to(current_user)}
    end
  end

  def show
    if params[:id].blank?
      @user = current_user
    else
      @user = User.find params[:id]
    end
    @items = @user.topics + @user.comments
    @items = @items.sort_by{|i| i.created_at}.reverse[0..9]
    puts 'gogogo'
  end

  def update_avatar_url
    respond_to do |format|
      if current_user.update_attribute(:avatar_url, params[:user][:avatar_url])
        flash[:notice] = 'Profile successfully updated.'
        format.html { redirect_to(current_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => current_user }
        format.xml  { render :xml => current_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def update
    current_user.photo = params[:user][:photo]
    respond_to do |format|
      if current_user.save
        flash[:notice] = 'Profile successfully updated.'
        format.html { redirect_to(current_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => current_user }
        format.xml  { render :xml => current_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      # log user in here
      self.current_user = @user
      redirect_back_or_default(@user)
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_user
    @user = User.find(params[:id])
  end
end
