# update Gemfile
puts "Installing related gems ..."
gsub_file "Gemfile", "# gem 'paperclip', git: 'git://github.com/thoughtbot/paperclip.git' # usage 'rails g paperclip user avatar'", "gem 'paperclip', git: 'git://github.com/thoughtbot/paperclip.git' # usage 'rails g paperclip user avatar'"
gsub_file "Gemfile", "# gem 'delayed_paperclip'", "gem 'delayed_paperclip'"
gsub_file "Gemfile", "# gem 'aws-sdk'", "gem 'aws-sdk'"
install_from_gemfile

# add default settings
puts "Adding default settings ..."
copy_static_file("config/settings/development.yml")
copy_static_file("config/settings/production.yml")
copy_static_file("config/settings/test.yml")
insert_into_file 'config/application.rb',%(

# Global defaults for Paperclip
  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {access_key_id: Settings.aws.access_key_id, secret_access_key: Settings.aws.secret_access_key},
    url: ':s3_domain_url',
    s3_permissions: "public-read",
    s3_region: ENV['S3_REGION'],
    bucket: Settings.s3.public.bucket,
    path: '/:class/:attachment/:id_partition/:style/:filename'
  }), after: "config.active_job.queue_adapter = :sidekiq"
puts "\n"

# attach to a model
if @add_paperclip_now
  puts "Generating related columns ..."
  run "bundle exec rails g paperclip #{@paperclip_model_downcased} #{@paperclip_column}; bundle exec rails g migration AddProcessingTo#{@paperclip_model} #{@paperclip_column}_processing:boolean"
  run "bundle exec rake db:migrate; bundle annotate"
  puts "\n"

  puts "Attaching to a model ..."
  insert_into_file "app/models/#{@paperclip_model_downcased}.rb",%(

  has_attached_file :#{@paperclip_column},
    styles: {large: '1500x1000#', small: '600x400#', wide: '1600x900#', ogp: '1200x630#', thumb: '300x300#'},
    path: Settings.s3.common.#{@paperclip_model_downcased}_image_path
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  process_in_background :#{@paperclip_column}, url_with_processing: false), after: "end"
  gsub_file "config/settings/development.yml", "XXX_image_path: ':class/images/:id/:filename/:style'", "#{@paperclip_model_downcased}_image_path: ':class/images/:id/:filename/:style'"
  gsub_file "config/settings/production.yml", "XXX_image_path: ':class/images/:id/:filename/:style'", "#{@paperclip_model_downcased}_image_path: ':class/images/:id/:filename/:style'"
  gsub_file "config/settings/test.yml", "XXX_image_path: ':class/images/:id/:filename/:style'", "#{@paperclip_model_downcased}_image_path: ':class/images/:id/:filename/:style'"
  puts "\n"

  # update strong paramaters
  puts "Updating strong paramaters ..."
  gsub_file "app/controllers/#{@paperclip_resources}_controller.rb", ".permit(", ".permit(:#{@paperclip_column}, "
  puts "\n"
end

git :add => "."
git :commit => "-aqm 'setup paperclip'"
puts "\n"
