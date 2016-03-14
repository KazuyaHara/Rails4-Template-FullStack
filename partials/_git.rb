# Create a .gitignore file and a new local repository, commit everything

puts "Initializing new Git repo ..."

remove_file '.gitignore'
file '.gitignore', <<-CODE.gsub(/^ {2}/, '')
  # Ignore bundler config.
  /.bundle

  # Ignore all logfiles and tempfiles.
  /log/*
  !/log/.keep
  /tmp

  # Ignore the Redis dump file.
  dump.rdb

  # Ignore .env file
  .env

  # Ignore settings
  config/settings.local.yml
  config/settings/*.local.yml
  config/environments/*.local.yml
CODE

git :init
git :add => "."
git :commit => "-aqm 'initial commit.'"

puts "\n"
