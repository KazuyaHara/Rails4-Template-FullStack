puts "Removing unnecessary files ... "
remove_file "README.rdoc"
file 'README.md', <<-CODE.gsub(/^ {2}/, '')
  # #{app_name}
  Hi, there! Good to see you.
CODE

puts "\n"
