# ----------------------------------------------------------------
# Rails4 FullStack Application Template Setup
# ----------------------------------------------------------------

# Directories for template partials and static files
@template_root = File.expand_path(File.join(File.dirname(__FILE__)))
@partials     = File.join(@template_root, 'partials')
@static_files = File.join(@template_root, 'files')

# Copy a static file from the template into the new application
def copy_static_file(path)
  puts "Installing #{path}..."
  remove_file path
  file path, File.read(File.join(@static_files, path))
  puts "\n"
end

def install_from_gemfile
  puts "Installing gems..."
  Bundler.with_clean_env do
    run 'bundle install --path vendor/bundle -j4'
  end
  puts "\n"

  git :add => '.'
  git :commit => "-aqm 'install bundled gems'"
  puts "\n"
end

puts "\n========================================================="
puts " Rails4 FullStack Application Template Setup"
puts "=========================================================\n"

apply "#{@partials}/_database.rb"
apply "#{@partials}/_puma.rb"
apply "#{@partials}/_rspec.rb"
apply "#{@partials}/_essentials.rb" # should run after '_rspec.rb'
apply "#{@partials}/_stylesheets.rb"
apply "#{@partials}/_devise.rb" if yes?('Use devise?([yes or ELSE])')
apply "#{@partials}/_background.rb" if yes?('Use background jobs?([yes or ELSE])') # should run after '_devise.rb'
apply "#{@partials}/_circleci.rb" if yes?('Use circle ci?([yes or ELSE])')
apply "#{@partials}/_codeclimate.rb" if yes?('Use codeclimate?([yes or ELSE])') # should run after '_rspec.rb'
