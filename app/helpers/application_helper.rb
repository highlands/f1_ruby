module ApplicationHelper

  def current_user
    session[:current_user].present? ? session[:current_user] : nil
  end

end
