module F1
  class RegistrationsController < F1::ApplicationController

    def new
    end

    def create
      connection = F1::Authenticate.new(ENV["F1_API_USER_USERNAME"], ENV["F1_API_USER_PASSWORD"])
      if connection.errors.present?
        flash[:alert] = connection.errors
        redirect_to f1.new_f1_user_registration_path
      else
        if connection.create_user(params["f1"], f1.new_f1_user_session_url)
          flash[:notice] = "Your account is pending. Please check your email to complete registration"
          redirect_to f1.new_f1_user_session_path
        else
          flash[:alert] = connection.errors
          redirect_to f1.new_f1_user_registration_path
        end
      end
    end

  end
end
