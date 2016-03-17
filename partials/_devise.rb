# update Gemfile
puts "Installing related gems to Devise ..."
uncomment_lines 'Gemfile', /gem 'bcrypt', '~> 3.1.7'/
uncomment_lines 'Gemfile', /gem 'devise'/
install_from_gemfile



# install devise
puts "Installing Devise ..."
run "bundle exec rails g devise:install"
puts "\n"

puts "Adding default_url_options ..."
insert_into_file 'config/environments/development.rb',%(
  config.action_mailer.default_url_options = {host: 'localhost', port: 3000}), after: "config.action_mailer.raise_delivery_errors = false"
puts "\n"

puts "Setting test helper ..."
insert_into_file 'spec/rails_helper.rb',%(
  config.include Devise::TestHelpers, type: :controller), after: 'RSpec.configure do |config|'
puts "\n"



# setup Model
puts "Generating authentication model ..."
model = ask("Type resource name (like 'Admin')")
columns = ask("If you need, type column names for #{model} model (like 'nick_name description:text')")
resources = model.pluralize.downcase
run "bundle exec rails g devise #{model} #{columns}; bundle exec rake db:migrate; bundle exec annotate"
puts "\n"



# setup View
puts "Generating views ..."
run "bundle exec rails g devise:views #{resources} -v registrations sessions passwords; bundle exec rake haml:replace_erbs"
uncomment_lines 'config/initializers/devise.rb', /config.scoped_views = true/
puts "\n"



# setup Controller
puts "Generating controllers ..."
run "bundle exec rails g devise:controllers #{resources}; bundle exec annotate"
remove_file "app/controllers/#{resources}/confirmations_controller.rb"
remove_file "app/controllers/#{resources}/omniauth_callbacks_controller.rb"
remove_file "app/controllers/#{resources}/unlocks_controller.rb"
puts "\n"



# Routing
puts "Adding routes ..."
gsub_file('config/routes.rb', /  devise_for :#{resources}\n/, '')
insert_into_file 'config/routes.rb',%(

  # Authentication
  devise_for :#{resources}, controllers: {
    registrations:      '#{resources}/registrations',
    sessions:           '#{resources}/sessions',
    passwords:          '#{resources}/passwords'
  }), after: "get '/sitemaps' => redirect(ENV['SITEMAP_HOST']) unless Rails.env.test?"
run "bundle exec annotate --routes"
puts "\n"



# i18n
puts "Adding a locale file ..."
copy_static_file "config/locales/devise.ja.yml"
puts "\n"



# commit
git :add => "."
git :commit => "-aqm 'install devise'"

# Omniauth
apply "#{@partials}/_omniauth.rb" if @using_omniauth
