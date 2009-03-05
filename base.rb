#Clear out todo and generate a nifty layout
run "echo TODO > README"
generate :nifty_layout
 
#Install gems
gem 'RedCloth', :lib => 'redcloth'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
rake "gems:install", :sudo => true
 
#Initiate git repo & add gitignore rules
git :init
 
file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END
 
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"
 
#Add initial stuff to git repo
git :add => ".", :commit => "-m 'initial commit'"
 
#Add nifty authentication if needed
if yes?("Do you want authentication?")
  name = ask("What do you want a user to be called?")
  generate :nifty_authentication, name
  rake "db:migrate"
 
  git :add => ".", :commit => "-m 'adding authentication'"
end
 
#Remove prototype files
  git :rm => "public/javascripts/controls.js"
  git :rm => "public/javascripts/dragdrop.js"
  git :rm => "public/javascripts/effects.js"
  git :rm => "public/javascripts/prototype.js"
  
inside('public/javascripts') do  
  #and add jquery
  run "cp ~/current_libs/jquery/* ."
  git :add => ".", :commit => "-m 'switching prototype for jquery'"
end
 
#Vendor rails
if yes?("Vendor rails?")
  inside('vendor') do
    run "git clone git://github.com/rails/rails.git"
  end
end
 
#Generate welcome controller for front page
generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"
git :add => ".", :commit => "-m 'adding welcome controller'"
 
if yes?("Deploy to Heroku?") do
  heroku create --remote
  git push heroku master
  puts "\n\nTo push to heroku, use:\n\n\tgit push heroku master\n\nfollowed by\n\nheroku rake db:migrate"
end
puts "\n\nTo push to github, use:\n\tgit push\n\n"
