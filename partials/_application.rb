puts "Setting default timezone to 'Tokyo'... "
gsub_file 'config/application.rb', /# config.time_zone = '.+'/, "config.time_zone = 'Tokyo'"

puts "Setting default locale to ':ja'... "
gsub_file 'config/application.rb', /# config.i18n.default_locale = :de/, "config.i18n.default_locale = :ja"

puts "Setting default generator... "
generators = <<-RUBY
config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      # g.test_framework :rspec,
      #   fixtures: true,
      #   view_specs: false,
      #   helper_specs: false,
      #   routing_specs: false,
      #   controller_specs: true,
      #   request_specs: false
      # g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
RUBY
application generators

git :add => '.'
git :commit => "-aqm 'set default TZ, locale and generator'"

puts "\n"
