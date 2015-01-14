module F1
  class RegistrationsController < F1::ApplicationController
    include F1::ApplicationHelper

    def new
      @user = F1::Authenticate.get_new_user
    end

    def create
      if F1::Authenticate.create_user(first_name: params[:user][:first_name], last_name: params[:user][:last_name], email: params[:user][:email])
        flash[:notice] = "Your account was successfully created!"
        redirect_to root_path
      else
        flash[:alert] = "There was an error creating your account, please try again"
        redirect_to new_f1_user_registration_path
      end
    end

  end
end
