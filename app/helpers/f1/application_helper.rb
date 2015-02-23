module F1
  module ApplicationHelper

    def validate_user
      current_user.is_valid?(cookies[:f1_oauth_token], cookies[:f1_oauth_token_secret])
    rescue
      false
    end

    def authenticate_user
      redirect_to f1.new_f1_user_session_path(redirect: request.env["REQUEST_URI"]) unless current_user
    end

    def current_user
      F1::User.find(cookies[:f1_user_id]) rescue nil
    end

    def current_admin
      current_user && current_user.is_a?(F1::Admin)
    end

    def f1_current_user
      token = cookies[:f1_oauth_token]
      secret = cookies[:f1_oauth_token_secret]
      if token.present? && secret.present?
        current_user.present? && token == current_user.token && secret == current_user.secret ? session[:f1_current_user] : false
      else
        false
      end
    end

  end
end
