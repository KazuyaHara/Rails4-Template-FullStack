# update Gemfile
puts "Installing Sidekiq, Sinatra and Redis for background job ..."
gsub_file 'Gemfile', /# gem 'sidekiq'/, "gem 'sidekiq'"
gsub_file 'Gemfile', /# gem 'sinatra', require: false/, "gem 'sinatra', require: false"
gsub_file 'Gemfile', /# gem 'redis', '~>3.2'/, "gem 'redis', '~>3.2'"
gsub_file 'Gemfile', /# gem 'redis-namespace'/, "gem 'redis-namespace'"
install_from_gemfile

# set queue adapter
puts "Setting ActiveJob queue adapter"
insert_into_file 'config/application.rb',%(
    # Active Job
    config.active_job.queue_adapter = :sidekiq
  ), after: "class Application < Rails::Application"
puts "\n"

# add sidekiq settings
puts "Adding sidekiq setting ..."
insert_into_file 'Procfile',%(
worker: bundle exec sidekiq -C config/sidekiq.yml), after: "web: bundle exec puma -C config/puma.rb"
copy_static_file "config/sidekiq.yml"
copy_static_file "config/initializers/sidekiq.rb"

# add routing for sidekiq dashboard
puts "Routing for sidekiq dashboard ..."
if @using_devise && yes?('Hide dashboard from unauthorized users? ([yes or ELSE])')
  namespace = ask("Type admin namespace like 'admin'")
  insert_into_file 'config/routes.rb',%(

  # sidekiq dashboard
  require 'sidekiq/web'
  authenticate :#{namespace} do
    mount Sidekiq::Web, at: '/sidekiq'
  end), after: "get '/sitemaps' => redirect(ENV['SITEMAP_HOST']) unless Rails.env.test?"
else
  insert_into_file 'config/routes.rb',%(

    # sidekiq dashboard
    require 'sidekiq/web'
    mount Sidekiq::Web, at: '/sidekiq'), after: "get '/sitemaps' => redirect(ENV['SITEMAP_HOST']) unless Rails.env.test?"
end
run "bundle exec annotate --routes"
puts "\n"

git :add => "."
git :commit => "-aqm 'setup sidekiq for background jobs'"

puts "\n"
