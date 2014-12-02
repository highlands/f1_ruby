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
      if Rails.env.test?
        F1::User.find_or_create_by(username: "dude")
      else
        F1::User.find(cookies[:f1_user_id])
      end
    rescue
      nil
    end

    def current_admin
      current_user && current_user.admin
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
