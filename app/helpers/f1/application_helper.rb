module F1
  module ApplicationHelper

    def current_user
      F1::User.find(cookies[:f1_user_id]).present? ? F1::User.find(cookies[:f1_user_id]) : nil
    end

    def f1_current_user
      token = cookies[:coth_oauth_token]
      secret = cookies[:coth_oauth_token_secret]
      if token.present? && secret.present?
        current_user.present? && token == current_user.token && secret == current_user.secret ? session[:f1_current_user] : false
      else
        false
      end
    end

  end
end
