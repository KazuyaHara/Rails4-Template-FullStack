puts "Setting circle ci ... "
file 'circle.yml', <<-CODE.gsub(/^ {2}/, '')
machine:
    timezone:
      Asia/Tokyo
    ruby:
      version: #{@ruby_version}
CODE
puts "\n"

git :add => '.'
git :commit => "-aqm 'setup ciecle ci'"

puts "\n"
