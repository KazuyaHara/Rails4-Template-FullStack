# convert css to scss
remove_file "app/assets/stylesheets/application.css"
copy_static_file 'app/assets/stylesheets/application.scss'
puts "\n"
