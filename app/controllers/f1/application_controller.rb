class F1::ApplicationController < ActionController::Base
  layout 'layouts/application'

  def validate_user
    user_id = F1::User.find_by(username: cookies[:f1_user]).id
    if F1::Authenticate.get_details(user_id)
      return true
    else
      return false
    end
  end
end
