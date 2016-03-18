# update Gemfile
puts "Installing related gems ..."
uncomment_lines 'Gemfile', /gem 'exception_notification'/
uncomment_lines 'Gemfile', /gem 'slack-notifier'/
install_from_gemfile

# copy initializer
puts "Adding initializer ..."
copy_static_file("config/initializers/exception_notification.rb")
if @oauth_with_twitter
insert_into_file '.env',%(

# Slack Settings for exception notification
SLACK_EXCEPTIONS_CHANNEL = 'XXXXXXXXXXXX'
SLACK_EXCEPTIONS_WEBHOOK_URL = 'XXXXXXXXXXXX'), after: "TWITTER_SECRET_KEY = 'XXXXXXXXXXXX'"
elsif @oauth_with_facebook
insert_into_file '.env',%(

# Slack Settings for exception notification
SLACK_EXCEPTIONS_CHANNEL = 'XXXXXXXXXXXX'
SLACK_EXCEPTIONS_WEBHOOK_URL = 'XXXXXXXXXXXX'), after: "FACEBOOK_SECRET_KEY = 'XXXXXXXXXXXX'"
else
insert_into_file '.env',%(

# Slack Settings for exception notification
SLACK_EXCEPTIONS_CHANNEL = 'XXXXXXXXXXXX'
SLACK_EXCEPTIONS_WEBHOOK_URL = 'XXXXXXXXXXXX'), after: "SITEMAP_HOST = 'http://yourbucket.s3-ap-northeast-1.amazonaws.com'"
end
puts "\n"

git :add => "."
git :commit => "-aqm 'install exception_notification'"
puts "\n"
