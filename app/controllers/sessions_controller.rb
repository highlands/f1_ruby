class SessionsController < ApplicationController

  def new
  end

  def create
    connection = F1.new(params[:user][:username], params[:user][:password])
    if connection.errors.present?
      flash[:alert] = connection.errors
      redirect_to root_path
    else
      if connection.oauth_token.present? && connection.oauth_token_secret.present?
        session[:oauth_token] = connection.oauth_token
        session[:oauth_token_secret] = connection.oauth_token_secret
        session[:f1_current_user] = connection.get_person["person"]
        redirect_to root_path
      else
        destroy
      end
    end
  end

  def destroy
    session[:f1_current_user] = session[:oauth_token] = session[:oauth_token_secret] = nil
    redirect_to root_path
  end

end
