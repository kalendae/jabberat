# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'uuid'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8104161735b644a3e3492ab4740dbab0'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  include AuthenticatedSystem

  before_filter :cookie_and_track

  def cookie_and_track
    # check for existence of cookie, drop cookie if doesn't exist
    unless params[:controller] == 'tracks'
      cv = cookies[:ta]
      if cookies[:ta].blank?
        uid = uuid
        cookies[:ta] = {:value => uid, :expires => 1.year.from_now}
        cv = uid
      end
      nopassword_parameters = request.parameters.blank? ? {} : request.parameters.clone
      nopassword_parameters.delete :password
      nopassword_parameters.delete :password_confirmation
      if nopassword_parameters.has_key? :user
        nopassword_parameters[:user].delete :password
        nopassword_parameters[:user].delete :password_confirmation
      end
      track = Track.new(:cookie => cv, :user_id => current_user.blank? ? nil : current_user.id, :path => request.path, :parameters => nopassword_parameters.inspect)
      track.save
    end
  end
  
  def super_user?
    current_user and (current_user.login == 'tao' or current_user.login == 'kalendae' or current_user.login == 'milener')
  end

  def redirect_post(redirect_post_params)
      controller_name = redirect_post_params[:controller]
      controller = "#{controller_name.camelize}Controller".constantize
      # Throw out existing params and merge the stored ones
      request.parameters.reject! { true }
      request.parameters.merge!(redirect_post_params)
      controller.process(request, response)
      if response.redirected_to
        @performed_redirect = true
      else
        @performed_render = true
      end
  end

  def uuid
    @uuid = UUID.new unless @uuid
    @uuid.generate
  end

end
