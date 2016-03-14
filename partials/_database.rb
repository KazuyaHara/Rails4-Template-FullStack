puts "Create database ..."
run "bundle exec rake db:create RAILS_ENV=development; bundle exec rake db:create RAILS_ENV=test"
