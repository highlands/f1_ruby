module F1
  class SessionsController < F1::ApplicationController
    include F1::ApplicationHelper

    def new
      if f1_current_user
        redirect_to f1.f1_user_path
      end
    end

    def create
      connection = F1::Authenticate.new(params[:user][:username], params[:user][:password])
      if connection.errors.present?
        flash[:alert] = connection.errors
        redirect_to root_path
      else
        if connection.oauth_token.present? && connection.oauth_token_secret.present?
          cookies[:coth_oauth_token] = connection.oauth_token
          cookies[:coth_oauth_token_secret] = connection.oauth_token_secret
          cookies[:f1_user] = params[:user][:username]
          session[:f1_current_user] = connection.get_person["person"]
          update_user
          redirect_to f1.root_path
        else
          destroy
        end
      end
    end

    def destroy
      session[:f1_current_user] = cookies[:coth_oauth_token] = cookies[:coth_oauth_token_secret] = nil
      redirect_to root_path
    end

    def show
      destroy unless validate_user
    end

    private

    def update_user
      user = F1::User.find_or_create_by(username: params[:user][:username])
      user.id = session[:f1_current_user]["@id"].to_i
      user.token = cookies[:coth_oauth_token]
      user.secret = cookies[:coth_oauth_token_secret]
      user.url = session[:f1_current_user]["@uri"]
      user.last_sign_in_ip = request.remote_ip
      user.save
    end

  end
end
