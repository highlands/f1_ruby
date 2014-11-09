F1::Engine.routes.draw do
  root 'sessions#new'
  get "sign_in"              => "sessions#new", as: "new_f1_user_session"
  post "sign_in"             => "sessions#create"
  get "destroy_f1_session"   => "sessions#destroy"
  get "me"                   => "sessions#show", as: "f1_user"
end
