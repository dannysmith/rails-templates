#Ask questions.

description = ask("Please provide a short description of your Project")

if yes?("Use Autlogic?")
  using_authlogic = true
  user_model_name = ask("What do you want a user to be called?")
else
  if yes?("Use nifty-auth without authlogic?")
    using_nifty_authentication = true
    user_model_name = ask("What do you want a user to be called?")
  end
end

#Set up Readme file formatted for GitHub with title and discription.
file 'README.markdown', <<-CODE
#{File.dirname(File.expand_path(__FILE__)).split("/")[-1].titleize}
===

==Description
#{description}

== Other Stuff
Blah...
CODE

#Install gems
gem "haml"
gem "authlogic" if using_authlogic

#gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
rake "gems:install", :sudo => true
 
#Install Plugins
# Attachments with no extra database tables, only one library to install for image processing
plugin 'paperclip', :git => "git://github.com/thoughtbot/paperclip.git"
       
#Initiate git repo & add gitignore rules
git :init

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

run "cp config/database.yml config/example_database.yml"
 
#Generate welcome controller for front page
generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
run "rm public/index.html"
 
#Remove prototype files
  run "rm public/javascripts/controls.js"
  run "rm public/javascripts/dragdrop.js"
  run "rm public/javascripts/effects.js"
  run "rm public/javascripts/prototype.js"

#Add nifty authentication or authlogic if needed
if using_authlogic
  generate :nifty_authentication, "--authlogic", user_model_name
  rake "db:migrate"
  git :add => ".", :commit => "-m 'adding authlogic authentication'"
end

if using_nifty_authentication
  generate :nifty_authentication, user_model_name
  rake "db:migrate"
  git :add => ".", :commit => "-m 'adding nifty_layouts authentication'"
end
  
#Add initial stuff to git repo
git :add => ".", :commit => "-m 'initial commit'"

puts "\nDon't forget to set up a github repository and set github as a remote by running\n\tgit remote add origin git@github.com:dannysmith/WHATEVER_THE_REPO_IS_CALLED.git\n\nAfter that, push to github using:\n\tgit push\n\n"