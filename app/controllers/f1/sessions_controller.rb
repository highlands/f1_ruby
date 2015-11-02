module F1
  class SessionsController < F1::ApplicationController
    include F1::ApplicationHelper
    before_filter :verify_user, :only => [:show, :edit]

    def new
      if f1_current_user
        redirect_to f1.f1_user_path
      end
      @forgot_password_url = "https://#{ENV["F1_CODE"]}.infellowship.com/UserLogin/ForgotPassword"
      @redirect = params[:redirect]
    end

    def create
      connection = F1::Authenticate.new(params[:user][:username], params[:user][:password], false)
      if connection.errors.present?
        flash[:alert] = connection.errors
        redirect_to f1.new_f1_user_session_path
      else
        if connection.oauth_token.present? && connection.oauth_token_secret.present?
          cookies.permanent.signed[:f1_oauth_token] = connection.oauth_token
          cookies.permanent.signed[:f1_oauth_token_secret] = connection.oauth_token_secret
          session[:f1_current_user] = connection.get_person["person"]
          extras = nil
          if F1::User.column_names.include?("data")
            extras = {}
            extras[:attributes] = connection.get_attributes["attributes"]
            extras[:peopleRequirements] = connection.get_requirements["peopleRequirements"]
          end
          update_user(extras)
          if params[:redirect].present?
            redirect_to params[:redirect]
          else
            redirect_after_login
          end
        else
          destroy
        end
      end
    end

    def edit
    end

    def update
      u = current_user
      u.image = params[:image]
      u.save
      redirect_to f1.f1_user_path
    end

    def destroy
      session[:f1_current_user] = cookies.permanent.signed[:f1_oauth_token] = cookies.permanent.signed[:f1_oauth_token_secret] = cookies.permanent.signed[:f1_user_id] = nil
      redirect_to main_app.root_path
    end

    def show
    end

    private

    def verify_user
      unless validate_user
        flash[:alert] = "You must be logged in to do that"
        destroy
      end
    end

    def update_user(extras = nil)
      user = F1::User.find_or_create_by(id: session[:f1_current_user]["@id"].to_i)
      if portal_user?(params[:user][:username])
        user.username = params[:user][:username]
        user.type = "F1::Admin"
      else
        user.email = params[:user][:username]
      end
      user.first_name = session[:f1_current_user]["firstName"]
      user.last_name = session[:f1_current_user]["lastName"]
      user.token = cookies.signed[:f1_oauth_token]
      user.secret = cookies.signed[:f1_oauth_token_secret]
      user.url = session[:f1_current_user]["@uri"]
      user.last_sign_in_ip = request.remote_ip
      user.data = extras if extras.present?
      user.save
      cookies.permanent.signed[:f1_user_id] = user.id
    end

    def portal_user?(username)
      !username.match(/@/) && !username.match(/\./)
    end

  end
end
