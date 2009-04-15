# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

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

  
end
