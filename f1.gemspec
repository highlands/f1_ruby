$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "f1/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "f1"
  s.version     = F1::VERSION
  s.authors     = ["JD Warren"]
  s.email       = ["jd@churchofthehighlands.com"]
  s.homepage    = "http://churchofthehighlands.com"
  s.summary     = "An authentication wrapper for Fellowship One in Ruby."
  s.description = "Pass in a username and password to authenticate against Fellowship One"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.7"
  s.add_development_dependency "sqlite3"

end
