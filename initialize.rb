# ----------------------------------------------------------------
# Rails4 FullStack Application Template
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

puts "\n========================================================="
puts " Rails4 FullStack Application Template"
puts "=========================================================\n"

copy_static_file 'Gemfile'
apply "#{@partials}/_git.rb"
