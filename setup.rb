# ----------------------------------------------------------------
# Rails4 FullStack Application Template Setup
# ----------------------------------------------------------------

# Directories for template partials and static files
@template_root = File.expand_path(File.join(File.dirname(__FILE__)))
@partials     = File.join(@template_root, 'partials')
@static_files = File.join(@template_root, 'files')

puts "\n========================================================="
puts " Rails4 FullStack Application Template Setup"
puts "=========================================================\n"

# Commit Gemfile.lock
git :add => '.'
git :commit => "-aqm 'Install bundled gems.'"

apply "#{@partials}/_rspec.rb"
