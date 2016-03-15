# for dotenv
puts "Setting puma ..."
copy_static_file "Procfile"
copy_static_file "config/puma.rb"
puts "\n"

git :add => '.'
git :commit => "-aqm 'add Procfile and Puma settings.'"

puts "\n"
