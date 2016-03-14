puts "Installing RSpec ... "
run "bin/rails generate rspec:install"
puts "\n"

puts "Coloring RSpec output ... "
run "echo '--color -f d' > .rspec"
puts "\n"

puts "Updating spec/rails_helper ..."
insert_into_file 'spec/rails_helper.rb',%(
require 'shoulda/matchers'
), after: '# Add additional requires below this line. Rails is not loaded until this point!'
insert_into_file 'spec/rails_helper.rb',%(
  config.include FactoryGirl::Syntax::Methods
), after: 'RSpec.configure do |config|'
puts "\n"

puts "Updating generator ..."
gsub_file 'config/application.rb', /# g.test_framework :rspec,/, "g.test_framework :rspec,"
gsub_file 'config/application.rb', /#   fixtures: true,/, "  fixtures: true,"
gsub_file 'config/application.rb', /#   view_specs: false,/, "  view_specs: false,"
gsub_file 'config/application.rb', /#   helper_specs: false,/, "  helper_specs: false,"
gsub_file 'config/application.rb', /#   routing_specs: false,/, "  routing_specs: false,"
gsub_file 'config/application.rb', /#   controller_specs: true,/, "  controller_specs: true,"
gsub_file 'config/application.rb', /#   request_specs: false/, "  request_specs: false"
gsub_file 'config/application.rb', /# g.fixture_replacement :factory_girl/, "g.fixture_replacement :factory_girl"
puts "\n"

puts "Adding binstub ..."
run "bundle binstubs rspec-core"
puts "\n"

puts "Integrating with Guard & Spring ..."
run "bundle exec guard init rspec"
run "bundle exec spring binstub rspec"
gsub_file 'Guardfile', /guard :rspec, cmd: "bundle exec rspec" do/, "guard :rspec, cmd: 'bundle exec spring rspec' do"
puts "\n"

git :add => '.'
git :commit => "-aqm 'Configured RSpec.'"

puts "\n"
