F1::Engine.routes.draw do
  root 'sessions#new'
  get "sign_in"              => "sessions#new", as: "new_f1_user_session"
  post "sign_in"             => "sessions#create"
  get "destroy_f1_session"   => "sessions#destroy"
  get "me"                   => "sessions#show", as: "f1_user"
  get "me/edit"              => "sessions#edit", as: "edit_f1_user"
  post "me/edit"             => "sessions#update", as: "update_f1_user"

  get "register"             => "registrations#new", as: "new_f1_user_registration"
  post "register"            => "registrations#create", as: "create_f1_user_registration"
end
