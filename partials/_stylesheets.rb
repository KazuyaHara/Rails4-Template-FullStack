# convert css to scss
puts "convert application.css to application.scss"
remove_file "app/assets/stylesheets/application.css"
copy_static_file 'app/assets/stylesheets/application.scss'
puts "\n"
