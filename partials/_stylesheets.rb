# convert css to scss
puts "convert application.css to application.scss"
remove_file "app/assets/stylesheets/application.css"
copy_static_file 'app/assets/stylesheets/application.scss'
puts "\n"

# for Bootstrap
@use_bootstrap = if yes?('Use bootstrap4?([yes or ELSE])')
  puts "Installing bootstrap4 ..."
  gsub_file 'Gemfile', /# gem 'bootstrap', '~> 4.0.0.alpha3'/, "gem 'bootstrap', '~> 4.0.0.alpha3'"
  gsub_file 'Gemfile', /# source 'https://rails-assets.org' do/, "source 'https://rails-assets.org' do"
  gsub_file 'Gemfile', /#   gem 'rails-assets-tether', '>= 1.1.0'/, "  gem 'rails-assets-tether', '>= 1.1.0'"
  gsub_file 'Gemfile', /# end/, "end"
  install_from_gemfile
  puts "\n"

  puts "Updating application.scss & application.js ..."
  insert_into_file 'app/assets/stylesheets/application.scss',%(
  @import "bootstrap";), after: "// Add additional styles below this line"
  insert_into_file 'app/assets/stylesheets/application.js',%(
  //= require tether
  //= require bootstrap-sprockets), after: "//= require jquery_ujs"
  puts "\n"
end

# for compass
@user_compass = if yes?('Use compass?([yes or ELSE])')
  puts "Installing compass ..."
  gsub_file 'Gemfile', /# gem 'compass-rails'/, "gem 'compass-rails'"
  install_from_gemfile
  puts "\n"

  puts "Updating application.scss ..."
  insert_into_file 'app/assets/stylesheets/application.scss',%(
  @import "compass";), after: "@import "bootstrap";"
  puts "\n"
end
