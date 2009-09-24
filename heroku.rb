load_template '/Users/danny/code/libs_and_repos/rails-templates/base.rb'

#Add Extra Stuff ------------
#Add Plugins
plugin 'sass_on_heroku', :git => 'git://github.com/heroku/sass_on_heroku.git'

#Add Gems File & Gems
file '.gems', <<-CODE
right_http_connection --version 1.2.4
right_aws --version 1.10.0
authlogic
CODE

gem 'right_http_connection'
gem 'right_aws'

#Adds Config File for Amazon S3.
file 'config/s3.yml', <<-CODE
access_key_id:
secret_access_key:
CODE

#Adds Fix for Paperclip
initializer 'paperclip.rb', <<-CODE
# config/initializers/paperclip.rb
# Added by hand to fix imagemagick problem.

# initializer solution for paperclip + passenger combo
# Paperclip::Attachment#post_process => "/tmp/stream.3916.0 is not recognized by the 'identify' 
# command" error.
if RAILS_ENV == "development"
  Paperclip.options[:image_magick_path] = "/opt/local/bin"
end
CODE

#Adds Email Settings to config
initializer 'email.rb', <<-CODE
# Load mail configuration if not in test environment
if RAILS_ENV == 'production'
  email_settings = YAML::load(File.open("\#{RAILS_ROOT}/config/email.yml"))
  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
end
CODE

file 'config/email.yml', <<-CODE
development:
  :address:
  :port: 25
  :authentication: login
  :user_name:
  :password:
production:
  :address:
  :port: 25
  :authentication: login
  :user_name:
  :password:
CODE

#Writes a few lines for email settings to the differenct enviroments config files.
File.open('config/environments/test.rb', "a") {|f| f.write "\nconfig.action_mailer.delivery_method = :test" }
File.open('config/environments/development.rb', "a") {|f| f.write "\nconfig.action_mailer.delivery_method = :test #:smtp" }
File.open('config/environments/production.rb', "a") {|f| f.write "\nconfig.action_mailer.delivery_method = :smtp" }

git :add => "."
git :commit => "-m 'setting up for heroku'"

#Create Heroku App --------------------------------
run 'heroku create --remote'
run 'git push heroku master'


puts "\nTo push to heroku, use:\n\n\tgit push heroku master\n\nfollowed by\n\n\theroku rake db:migrate"

