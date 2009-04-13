class StartController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  def index
    unless params[:t].blank?
      # TODO: this should be a ferret fuzzy search
      @topics = Topic.find_all_by_content(params[:t])
      @content = params[:t]
    end 
  end
  
end
