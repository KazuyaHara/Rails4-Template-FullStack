# Install omniauth gem
puts "Installing gem 'omniauth' ..."
uncomment_lines 'Gemfile', /gem 'omniauth'/
install_from_gemfile

# Install settings
puts "Adding setting files ..."
copy_static_file "config/omniauth.yml"
@rails_root = '#{Rails.root}'
insert_into_file 'config/initializers/devise.rb',%(OAUTH_CONFIG = YAML.load(ERB.new(File.read("#{@rails_root}/config/omniauth.yml")).result)[Rails.env].symbolize_keys!

  # https://github.com/mkdynamic/omniauth-facebook
  # https://developers.facebook.com/docs/concepts/login/
  # config.omniauth :facebook, OAUTH_CONFIG[:facebook]['key'], OAUTH_CONFIG[:facebook]['secret'], scope: 'email', image_size: 'large'

  # https://github.com/arunagw/omniauth-twitter
  # https://dev.twitter.com/docs/api/1.1
  # config.omniauth :twitter, OAUTH_CONFIG[:twitter]['key'], OAUTH_CONFIG[:twitter]['secret'], image_size: 'original'

  # https://github.com/zquestz/omniauth-google-oauth2
  # https://developers.google.com/accounts/docs/OAuth2
  # https://developers.google.com/+/api/oauth
  # config.omniauth :google_oauth2, OAUTH_CONFIG[:google]['key'], OAUTH_CONFIG[:google]['secret'], scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/plus.me https://www.google.com/m8/feeds', name: :google

  # https://github.com/mururu/omniauth-hatena
  # http://developer.hatena.ne.jp/ja/documents/auth/apis/oauth
  # config.omniauth :hatena, OAUTH_CONFIG[:hatena]['key'], OAUTH_CONFIG[:hatena]['secret']

  # https://github.com/intridea/omniauth-github
  # http://developer.github.com/v3/oauth/
  # http://developer.github.com/v3/oauth/#scopes
  # config.omniauth :github, OAUTH_CONFIG[:github]['key'], OAUTH_CONFIG[:github]['secret'], scope: 'user,public_repo'

  # https://github.com/skorks/omniauth-linkedin
  # https://developer.linkedin.com/documents/authentication
  # https://developer.linkedin.com/documents/profile-fields
  # config.omniauth :linkedin, OAUTH_CONFIG[:linkedin]['key'], OAUTH_CONFIG[:linkedin]['secret'], scope: 'r_basicprofile r_emailaddress r_network',
  #   fields: [
  #     "id", "first-name", "last-name", "formatted-name", "headline", "location", "industry", "summary", "specialties", "positions", "picture-url", "public-profile-url", # in r_basicprofile
  #     "email-address",  # in r_emailaddress
  #     "connections"  # in r_network
  #   ]

  # https://github.com/pivotal-sushi/omniauth-mixi
  # http://developer.mixi.co.jp/connect/mixi_graph_api/api_auth/
  # config.omniauth :mixi, OAUTH_CONFIG[:mixi]['key'], OAUTH_CONFIG[:mixi]['secret']
), before: '# ==> Warden configuration'
puts "\n"



# Create SocialProfile model
puts "Creating SocialProfile model ..."

unless @parent_model_exists
  # setup Model
  puts "Generating #{@parent_model} model ..."
  run "bundle exec rails g devise #{@parent_model} #{@parent_columns}; bundle exec rake db:migrate; bundle exec annotate"
  puts "\n"

  # setup View
  puts "Generating #{@parent_model} views ..."
  run "bundle exec rails g devise:views #{@parent_resources} -v registrations sessions passwords; bundle exec rake haml:replace_erbs"
  puts "\n"

  # setup Controller
  puts "Generating #{@parent_model} controllers ..."
  run "bundle exec rails g devise:controllers #{@parent_resources}; bundle exec annotate"
  remove_file "app/controllers/#{@parent_resources}/confirmations_controller.rb"
  remove_file "app/controllers/#{@parent_resources}/omniauth_callbacks_controller.rb"
  remove_file "app/controllers/#{@parent_resources}/unlocks_controller.rb"
  puts "\n"

  # Routing
  puts "Adding routes ..."
  gsub_file('config/routes.rb', /  devise_for :#{@parent_resources}\n/, '')
  insert_into_file 'config/routes.rb',%(

    # Authentication
    devise_for :#{@parent_resources}, controllers: {
      registrations:      '#{@parent_resources}/registrations',
      sessions:           '#{@parent_resources}/sessions',
      passwords:          '#{@parent_resources}/passwords'
    }
    ), after: "get '/sitemaps' => redirect(ENV['SITEMAP_HOST']) unless Rails.env.test?"
  run "bundle exec annotate --routes"
  puts "\n"
end

run "bundle exec rails g model SocialProfile #{@parent_model_downcased}:references provider uid access_token access_secret name nickname email url image_url description other:text credentials:text raw_info:text"
@uid = "uid"
insert_into_file 'app/models/social_profile.rb',%(
  store :other
  validates_uniqueness_of :uid, scope: :provider

  def set_values(omniauth)
    return if provider.to_s != omniauth['provider'].to_s || uid != omniauth['uid']
    credentials = omniauth['credentials']
    info = omniauth['info']

    self.access_token = credentials['token']
    self.access_secret = credentials['secret']
    self.credentials = credentials.to_json
    self.email = info['email']
    self.name = info['name']
    self.nickname = info['nickname']
    self.description = info['description'].try(:truncate, 255)
    self.image_url = info['image']
    # case provider.to_s
    # when 'twitter'
    #   self.url = info['urls']['Twitter']
    #   self.other[:location] = info['location']
    #   self.other[:website] = info['urls']['Website']
    # when 'hatena'
    #   self.url = "https://www.hatena.ne.jp/#{@uid}/"
    # when 'linkedin'
    #   self.url = info['urls']['public_profile']
    # when 'google'
    #   self.nickname ||= info['email'].sub(/(.+)@gmail.com/, '\1')
    # when 'github'
    #   self.url = info['urls']['GitHub']
    #   self.other[:blog] = info['urls']['Blog']
    # when 'mixi'
    #   self.url = info['urls']['profile']
    # end

    self.set_values_by_raw_info(omniauth['extra']['raw_info'])
  end

  def set_values_by_raw_info(raw_info)
    # case provider.to_s
    # when 'twitter'
    #   self.other[:followers_count] = raw_info['followers_count']
    #   self.other[:friends_count] = raw_info['friends_count']
    #   self.other[:statuses_count] = raw_info['statuses_count']
    # when 'google'
    #   self.url = raw_info['link']
    # end

    self.raw_info = raw_info.to_json
    self.save!
  end), after: "belongs_to :#{@parent_model_downcased}"
copy_static_file "db/migrate/20160401000001_add_index_to_social_profile.rb"
gsub_file "app/models/#{@parent_model_downcased}.rb", /# :confirmable, :lockable, :timeoutable and :omniauthable/, "# :confirmable, :lockable and :timeoutable"
gsub_file "app/models/#{@parent_model_downcased}.rb", /devise :database_authenticatable, :registerable,/, "devise :database_authenticatable, :registerable, :omniauthable,"
run "bundle exec rake db:migrate; bundle exec annotate"
puts "\n"



# Update parent model
puts "Updating #{@parent_model} model ..."
insert_into_file "app/models/#{@parent_model_downcased}.rb",%(

  has_many :social_profiles, dependent: :destroy

  def social_profile(provider)
    social_profiles.select{ |sp| sp.provider == provider.to_s }.first
  end), after: ':recoverable, :rememberable, :trackable, :validatable'
run "bundle exec rails g migration AddDummyEmailTo#{@parent_model} dummy_email:boolean:index"
gsub_file "#{Dir.glob("db/migrate/*.rb").last}", /add_column :#{@parent_resources}, :dummy_email, :boolean/, "add_column :#{@parent_resources}, :dummy_email, :boolean, default: false"
run "bundle exec rake db:migrate; bundle exec annotate"
puts "\n"



# Create OmniauthCallbacks controller
puts "Creating OmniauthCallbacks controller ..."
run "bundle exec rails g controller #{@parent_resources}/OmniauthCallbacks"
remove_dir "app/views/#{@parent_resources}/omniauth_callbacks"
gsub_file "app/controllers/#{@parent_resources}/omniauth_callbacks_controller.rb", /ApplicationController/, "Devise::OmniauthCallbacksController"
@provider = "@omniauth['provider']"
@dummy = '#{name}-#{SecureRandom.hex(10)}@example.com'
@sign_in_path = "sign_in(:#{@parent_model_downcased}, @profile.#{@parent_model_downcased})"
insert_into_file "app/controllers/#{@parent_resources}/omniauth_callbacks_controller.rb",%(
  # def facebook; basic_action; end
  # def twitter; basic_action; end
  # def google; basic_action; end
  # def hatena; basic_action; end
  # def linkedin; basic_action; end
  # def github; basic_action; end
  # def mixi; basic_action; end

  private
    def basic_action
      @omniauth = request.env['omniauth.auth']
      if @omniauth.present?
        @profile = SocialProfile.where(provider: @omniauth['provider'], uid: @omniauth['uid']).first

        if @profile && @omniauth['credentials']['secret'] != @profile.access_secret
          @profile.update(access_secret: @omniauth['credentials']['secret'])
        elsif @profile.nil?
          begin
            @profile = SocialProfile.where(provider: @omniauth['provider'], uid: @omniauth['uid']).new
            @user_data = set_user_data
            @profile.#{@parent_model_downcased} = current_#{@parent_model_downcased} || #{@parent_model}.create!(email: @user_data[:email], password: Devise.friendly_token[0,20], dummy_email: @user_data[:dummy_email])
            @profile.save!
          rescue => e
            logger.error e
            if request.env["HTTP_REFERER"]
              return redirect_to :back, alert: "入力した内容に誤りがあります"
            else
              return redirect_to root_path, alert: "入力した内容に誤りがあります"
            end
          end
        end

        if current_#{@parent_model_downcased}
          return redirect_to :back, alert: "この#{@provider} IDはすでに別のアカウントで使用されています" if current_#{@parent_model_downcased} != @profile.#{@parent_model_downcased}
        else
          #{@sign_in_path}
        end

        @profile.set_values(@omniauth)
      end

      return redirect_to request.env['omniauth.origin'] || root_path
    end

    def set_user_data
      @omniauthparams = request.env['omniauth.params']
      name = @omniauthparams['name']
      email = @omniauth['info']['email'] ||= "#{@dummy}"
      dummy_flag = @omniauth['provider'] == "twitter" ? "true" : "false"
      {name: name, email: email, dummy_email: dummy_flag}
    end), after: "class #{@parent_model_pluralized}::OmniauthCallbacksController < Devise::OmniauthCallbacksController"
puts "\n"



# Add routing
puts "Adding routes ..."
insert_into_file 'config/routes.rb',%(
    omniauth_callbacks: '#{@parent_resources}/omniauth_callbacks',), after: "devise_for :#{@parent_resources}, controllers: {"
run "bundle exec annotate --routes"
puts "\n"



# Commit
git :add => "."
git :commit => "-aqm 'generate SocialProfile model & OmniauthCallbacks controller'"
puts "\n"



# Select provider
if @oauth_with_facebook
puts "Adding omniauth-facebook ..."
uncomment_lines 'Gemfile', /gem 'omniauth-facebook'/
install_from_gemfile
uncomment_lines "app/controllers/#{@parent_resources}/omniauth_callbacks_controller.rb", /def facebook; basic_action; end/
gsub_file "config/omniauth.yml", "# facebook:", "facebook:"
gsub_file "config/omniauth.yml", "#   key: <%= ENV['FACEBOOK_APP_ID'] %>", "  key: <%= ENV['FACEBOOK_APP_ID'] %>"
gsub_file "config/omniauth.yml", "#   secret: <%= ENV['FACEBOOK_SECRET_KEY'] %>", "  secret: <%= ENV['FACEBOOK_SECRET_KEY'] %>"
gsub_file "config/initializers/devise.rb", "# config.omniauth :facebook, OAUTH_CONFIG[:facebook]['key'], OAUTH_CONFIG[:facebook]['secret'], scope: 'email', image_size: 'large'", "config.omniauth :facebook, OAUTH_CONFIG[:facebook]['key'], OAUTH_CONFIG[:facebook]['secret'], scope: 'email', image_size: 'large'"
insert_into_file '.env',%(

# Omniauth Setting
FACEBOOK_APP_ID = 'XXXXXXXXXXXX'
FACEBOOK_SECRET_KEY = 'XXXXXXXXXXXX'), after: "SITEMAP_HOST = 'http://yourbucket.s3-ap-northeast-1.amazonaws.com'"
puts "\n"

git :add => "."
git :commit => "-aqm 'integrate with facebook omniauth'"
puts "\n"
end
if @oauth_with_twitter
puts "Adding omniauth-twitter ..."
uncomment_lines 'Gemfile', /gem 'omniauth-twitter'/
install_from_gemfile
uncomment_lines "app/controllers/#{@parent_resources}/omniauth_callbacks_controller.rb", /def twitter; basic_action; end/
gsub_file "config/omniauth.yml", "# twitter:", "twitter:"
gsub_file "config/omniauth.yml", "#   key: <%= ENV['TWITTER_APP_ID'] %>", "  key: <%= ENV['TWITTER_APP_ID'] %>"
gsub_file "config/omniauth.yml", "#   secret: <%= ENV['TWITTER_SECRET_KEY'] %>", "  secret: <%= ENV['TWITTER_SECRET_KEY'] %>"
gsub_file "config/initializers/devise.rb", "# config.omniauth :twitter, OAUTH_CONFIG[:twitter]['key'], OAUTH_CONFIG[:twitter]['secret'], image_size: 'original'", "config.omniauth :twitter, OAUTH_CONFIG[:twitter]['key'], OAUTH_CONFIG[:twitter]['secret'], image_size: 'original'"
gsub_file "app/models/social_profile.rb", "# case provider.to_s", "case provider.to_s"
gsub_file "app/models/social_profile.rb", "# when 'twitter'", "when 'twitter'"
gsub_file "app/models/social_profile.rb", "#   self.url = info['urls']['Twitter']", "  self.url = info['urls']['Twitter']"
gsub_file "app/models/social_profile.rb", "#   self.other[:location] = info['location']", "  self.other[:location] = info['location']"
gsub_file "app/models/social_profile.rb", "#   self.other[:website] = info['urls']['Website']", "  self.other[:website] = info['urls']['Website']"
gsub_file "app/models/social_profile.rb", "#   self.other[:followers_count] = raw_info['followers_count']", "  self.other[:followers_count] = raw_info['followers_count']"
gsub_file "app/models/social_profile.rb", "#   self.other[:friends_count] = raw_info['friends_count']", "  self.other[:friends_count] = raw_info['friends_count']"
gsub_file "app/models/social_profile.rb", "#   self.other[:statuses_count] = raw_info['statuses_count']", "  self.other[:statuses_count] = raw_info['statuses_count']"
gsub_file "app/models/social_profile.rb", "# end", "end"
if @oauth_with_facebook
insert_into_file '.env',%(
TWITTER_APP_ID = 'XXXXXXXXXXXX'
TWITTER_SECRET_KEY = 'XXXXXXXXXXXX'), after: "FACEBOOK_SECRET_KEY = 'XXXXXXXXXXXX'"
else
insert_into_file '.env',%(

# Omniauth Setting
TWITTER_APP_ID = 'XXXXXXXXXXXX'
TWITTER_SECRET_KEY = 'XXXXXXXXXXXX'), after: "SITEMAP_HOST = 'http://yourbucket.s3-ap-northeast-1.amazonaws.com'"
end
puts "\n"

git :add => "."
git :commit => "-aqm 'integrate with twitter omniauth'"
puts "\n"
end
