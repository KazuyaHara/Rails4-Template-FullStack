# convert css to scss
puts "convert application.css to application.scss"
remove_file "app/assets/stylesheets/application.css"
copy_static_file 'app/assets/stylesheets/application.scss'
puts "\n"

# for Bootstrap
if yes?('Use bootstrap4?([yes or ELSE])')
@using_bootstrap = true
puts "Installing bootstrap4 ..."
gsub_file 'Gemfile', /# gem 'bootstrap', '~> 4.0.0.alpha3'/, "gem 'bootstrap', '~> 4.0.0.alpha3'"
gsub_file 'Gemfile', /# rails-assets-source/, "source 'https://rails-assets.org'"
gsub_file 'Gemfile', /#   gem 'rails-assets-tether', '>= 1.1.0'/, "  gem 'rails-assets-tether', '>= 1.1.0'"
gsub_file 'Gemfile', /# end/, "end"
install_from_gemfile
puts "\n"

puts "Updating application.scss & application.js ..."
insert_into_file 'app/assets/stylesheets/application.scss',%(
@import "bootstrap";), after: "// Add additional styles below this line"
insert_into_file 'app/assets/javascripts/application.js',%(
//= require tether
//= require bootstrap-sprockets), after: "//= require jquery_ujs"
puts "\n"
end

# for compass
if yes?('Use compass?([yes or ELSE])')
@using_compass = true
puts "Installing compass ..."
gsub_file 'Gemfile', /# gem 'compass-rails'/, "gem 'compass-rails'"
install_from_gemfile
puts "\n"

puts "Updating application.scss ..."
if @using_bootstrap
insert_into_file 'app/assets/stylesheets/application.scss',%(
@import "compass";), after: '@import "bootstrap";'
else
insert_into_file 'app/assets/stylesheets/application.scss',%(
@import "compass";), after: '// Add additional styles below this line'
end
puts "\n"
end

# for Font Awesome
if yes?('Use font awesome?([yes or ELSE])')
@using_fontawesome = true
puts "Installing Font Awesome ..."
gsub_file 'Gemfile', /# gem 'font-awesome-rails'/, "gem 'font-awesome-rails'"
install_from_gemfile
puts "\n"

puts "Updating application.scss ..."
if @using_compass
insert_into_file 'app/assets/stylesheets/application.scss',%(
@import "font-awesome";), after: '@import "compass";'
elsif @using_bootstrap
insert_into_file 'app/assets/stylesheets/application.scss',%(
@import "font-awesome";), after: '@import "bootstrap";'
else
insert_into_file 'app/assets/stylesheets/application.scss',%(
@import "font-awesome";), after: '// Add additional styles below this line'
end
puts "\n"
end
