# ----------------------------------------------------------------
# Rails4 FullStack Application Template Initialize
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
puts " Rails4 FullStack Application Template Initialize"
puts "=========================================================\n"

copy_static_file 'Gemfile'
apply "#{@partials}/_cleanup.rb"
apply "#{@partials}/_git.rb"
install_from_gemfile
apply "#{@partials}/_application.rb"
