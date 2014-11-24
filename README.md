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


#### Helper Methods:

    current_user

This gets you the user object created when the current user logged in with F1 credentials.

