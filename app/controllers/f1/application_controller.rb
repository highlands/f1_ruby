class F1::ApplicationController < ActionController::Base
  layout 'layouts/application'

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
end
