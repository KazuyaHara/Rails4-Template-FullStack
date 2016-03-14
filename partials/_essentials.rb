# for dotenv
puts "Add .env file ..."
add_file ".env"
puts "\n"

# for annotate
puts "Annotating ..."
remove_file 'config/routes.rb'
file 'config/routes.rb', <<-CODE.gsub(/^ {2}/, '')
  # bundle exec annotate --routes

  Rails.application.routes.draw do
  end
CODE
run "bundle exec annotate --routes"
run "bundle exec annotate"
puts "\n"

# for Bullet
puts "Adding Bullet settings ..."
insert_into_file 'config/environments/development.rb',%(
  # notify N+1 problem
  config.after_initialize do
    Bullet.enable  = true
    Bullet.alert   = true
    Bullet.bullet_logger = false
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer   = true
  end), after: 'config.assets.debug = true'
puts "\n"

# for erb2haml
puts "Converting erb to haml ..."
run 'bundle exec rake haml:replace_erbs'
puts "\n"
