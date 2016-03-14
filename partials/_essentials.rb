# for dotenv
puts "Add .env file ..."
add_file ".env"
puts "\n"

# for annotate
puts "Annotating ..."
remove_file 'config/routes.rb'
file 'config/routes.rb', <<-CODE.gsub(/^ {2}/, '')
  # bundle exec annotate --routes

  Rails.application.routes.draw do
  end
CODE
run "bundle exec annotate --routes"
run "bundle exec annotate"
puts "\n"

# for Bullet
puts "Adding Bullet settings ..."
insert_into_file 'config/environments/development.rb',%(

  # notify N+1 problem
  config.after_initialize do
    Bullet.enable  = true
    Bullet.alert   = true
    Bullet.bullet_logger = false
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer   = true
  end), after: 'config.assets.debug = true'
puts "\n"

# for erb2haml
puts "Converting erb to haml ..."
run 'bundle exec rake haml:replace_erbs'
puts "\n"

# for config
puts "Installing config ..."
run "bundle exec rails g config:install"
puts "\n"

# for friendly_id
puts "Installing friendly_id ..."
run "bundle exec rails g friendly_id; bundle exec rake db:migrate"
puts "\n"

# for kaminari
puts "Installing kaminari ..."
run "bundle exec rails g kaminari:config"
run "bundle exec rails g kaminari:views bootstrap3"
puts "\n"

# for meta-tags
puts "Setting meta-tags ..."
gsub_file 'app/views/layouts/application.html.haml', /%title Appname/, "= render partial: 'layouts/meta_tags'"
file 'app/views/layouts/_meta_tags.html.haml', <<-CODE.gsub(/^ {2}/, '')
%meta{charset: 'UTF-8'}
%meta{name: 'viewport', content: 'width=device-width, initial-scale=1.0'}
%meta{content: 'NOYDIR', name: 'ROBOTS'}
%meta{content: 'NOODP', name: 'ROBOTS'}
= display_meta_tags default_meta_tags
CODE
insert_into_file 'app/helpers/application_helper.rb',%(
  def default_meta_tags
    {
      site: Settings.site[:name],
      reverse: true,
      description: Settings.site[:page_description],
      og: {
        title: Settings.site[:name],
        type: Settings.site[:meta][:og][:type],
        url: root_url,
        image: image_url(Settings.site[:meta][:og][:image]),
        site_name: :site,
        description: :description,
        locale: 'ja_JP'
      },
      twitter: {
        card: Settings.site[:meta][:twitter][:card],
        site: Settings.site[:meta][:twitter][:site],
        title: Settings.site[:name],
        description: Settings.site[:page_description],
        image: {_: image_url(Settings.site[:meta][:og][:image])}
        }
      }
  end), after: 'module ApplicationHelper'
remove_file 'config/settings.yml'
file 'config/settings.yml', <<-CODE.gsub(/^ {2}/, '')
site:
  name: "#{app_name}"
  page_description: ""

  meta:
    og:
      type: 'website'
      image: 'sample.jpg'
    twitter:
      card: 'summary_large_image'
      site: '@XXXX'
CODE
puts "\n"

git :add => "."
git :commit => "-aqm 'install essential gems'"

puts "\n"
