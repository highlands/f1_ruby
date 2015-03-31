# Fellowship One Ruby

### Dependencies:

Rails 4

### Setup

Add gem to Gemfile:

    gem 'f1', :git => "git@github.com:highlands/single_sign_on.git"

#### Bundle:

    bundle

#### Copy over migrations:

    rake f1:install:migrations

#### Migrate database:

    rake db:migrate

#### Add Route to config/routes.rb :

    mount F1::Engine => "/users", :as => "f1"

##### Now all authentication routes should be prefixed with 'f1'

##### For instance:

    f1.new_f1_user_session_path

    f1.new_f1_user_registration_path

#### Helper Methods:

    current_user

This gets you the user object created when the current user logged in with F1 credentials.

    f1_current_user

This gets you the string returned by F1 when the user logged in. It contains the user's details in a hash.

