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

apply "#{@partials}/_questionnaires.rb"
apply "#{@partials}/_database.rb"
apply "#{@partials}/_puma.rb"
apply "#{@partials}/_rspec.rb"
apply "#{@partials}/_essentials.rb" # should run after '_rspec.rb'
apply "#{@partials}/_stylesheets.rb"
apply "#{@partials}/_devise.rb" if @using_devise
apply "#{@partials}/_background.rb" if @using_background # should run after '_devise.rb'
apply "#{@partials}/_paperclip.rb" if @using_paperclip # should run after '_background.rb'
apply "#{@partials}/_paramater_sanitizer.rb" if @using_omniauth || @using_paperclip # should run after '_paperclip.rb'
apply "#{@partials}/_notification.rb" if @using_notification
apply "#{@partials}/_circleci.rb" if @using_circleci
apply "#{@partials}/_codeclimate.rb" if @using_codeclimate # should run after '_rspec.rb'

puts "\n\n\n========================================================="
puts " Setup completed. Let's code!!"
puts "=========================================================\n\n\n\n\n"
