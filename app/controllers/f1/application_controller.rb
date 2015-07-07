class F1::ApplicationController < ActionController::Base
  layout 'layouts/application'

  def redirect_after_login
    redirect_to f1.new_f1_user_session_path
  end

end
