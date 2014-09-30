module ApplicationHelper

  def f1_current_user
    session[:f1_current_user].present? ? session[:f1_current_user] : nil
  end

end
