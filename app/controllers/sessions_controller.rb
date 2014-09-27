class SessionsController < ApplicationController

  def new
  end

  def create
    resp = F1.new(params[:user][:username], params[:user][:password])
    if resp.oauth_token.present? && resp.oauth_token_secret.present?
      session[:oauth_token] = resp.oauth_token
      session[:oauth_token_secret] = resp.oauth_token_secret
      session[:current_user] = params[:user][:username]
      redirect_to root_path
    else
      destroy
    end
  end

  def destroy
    session[:current_user] = session[:oauth_token] = session[:oauth_token_secret] = nil
    redirect_to root_path
  end

end
