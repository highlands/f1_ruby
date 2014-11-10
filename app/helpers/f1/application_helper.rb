module F1
  module ApplicationHelper

    def validate_user
      user_id = F1::User.find(cookies[:f1_user_id]).id
      if F1::Authenticate.get_details(user_id)
        return true
      else
        return false
      end
    rescue
      return false
    end

    def current_user
      F1::User.find(cookies[:f1_user_id])
    rescue
      nil
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
