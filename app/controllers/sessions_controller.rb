class SessionsController < ApplicationController
  def create
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    render json: { message: "Signed In!" }
  end
  
  def destroy
    session[:user_id] = nil
    render json: { message: "Signed Out!" }
  end
  
  protected

  def auth
    request.env['omniauth.auth']
  end
end