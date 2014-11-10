module F1
  module ApplicationHelper

    def f1_current_user
      token = cookies[:coth_oauth_token]
      secret = cookies[:coth_oauth_token_secret]
      if token.present? && secret.present?
        user = F1::User.find_by(username: cookies["f1_user"])
        user.present? && token == user.token && secret == user.secret ? session[:f1_current_user] : false
      else
        false
      end
    end

    def f1_username
      if cookies["f1_user"].present?
        cookies["f1_user"]
      else
        redirect_to  destroy_f1_session_path
      end
    end

  end
end
