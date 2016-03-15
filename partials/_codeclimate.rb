puts "Installing codeclimate test reporter ... "
gsub_file 'Gemfile', /# gem 'codeclimate-test-reporter', require: nil/, "gem 'codeclimate-test-reporter', require: nil"
Bundler.with_clean_env do
  run 'bundle install'
end
puts "\n"

copy_static_file ".codeclimate.yml"
insert_into_file 'spec/rails_helper.rb',%(
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start), after: "require 'rspec/active_job'"
puts "\n"

git :add => '.'
git :commit => "-aqm 'setup codeclimate'"

puts "\n"
