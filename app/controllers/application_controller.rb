class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user
  
  def require_login
    redirect_to root_path unless current_user
  end
  
  private
  
  def not_authenticated
    redirect_to login_url, :alert => "First log in to view this page."
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
