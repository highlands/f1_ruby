# Fellowship One Ruby

### Dependencies:

Rails 4

### Setup

Add gem to Gemfile:

    gem 'f1', :github => "highlands/f1_ruby"

#### Bundle:

    bundle

#### Copy over migrations:

    rake f1:install:migrations

#### Migrate database:

    rake db:migrate

#### Add Route to config/routes.rb :

    mount F1::Engine => "/users", :as => "f1"

#### Add Fellowship One Api Key, Secret, and Church code as environment variables in .bashrc. If you have a staging Fellowship One account, you can add those too.

    export F1_CODE="YOUR_CHUCH_CODE"

    # development (staging) keys

    export F1_KEY_STAGING="xxx"
    export F1_SECRET_STAGING="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    # production keys

    export F1_KEY="xxx"
    export F1_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

You will need to source your bashrc file after adding. Either close/re-open all terminal windows or run:

    source ~/.bashrc

Then restart your rails server.

    rails s


##### Sign in

You can sign in by going to the following url:

    http://localhost:3000/users/sign_in

Then enter your F1 username or email and valid password. This gem will work with either a Portal User's username or a Weblink User's email address and distinguish between the two automatically.

If your login is successful, you should be redirected to a page with your F1 user's data. If there is an error, you should be redirected back to the login page with an error (Rails flash) message available.

## Routes

##### Now all authentication routes should be prefixed with 'f1', for instance:

    f1.new_f1_user_session_path

    f1.new_f1_user_registration_path

#### Helper Methods:

To access helper methods in this gem, you must include the following in the top of your application controller (or any specific controller you wish):

    include F1::ApplicationHelper

You can then access the following:

    current_user

This gets you the user object created when the current user logged in with F1 credentials.

    f1_current_user

This gets you the string returned by F1 when the user logged in. It contains the user's details in a hash.



