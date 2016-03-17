# handling typed resource name
def singularized_and_capitalized(string)
  string.singularize.capitalize
end

def singularized_and_downcased(string)
  string.singularize.downcase
end

def pluralized_and_capitalized(string)
  string.pluralize.capitalize
end

def pluralized_and_downcased(string)
  string.pluralize.downcase
end



# about styling
@using_bootstrap = true if yes?('Use bootstrap4?([yes or ELSE])')
@using_compass = true if yes?('Use compass?([yes or ELSE])')
@using_fontawesome = true if yes?('Use font awesome?([yes or ELSE])')

# about authentication
@using_devise = true if yes?('Use devise?([yes or ELSE])')
if @using_devise
  @model_original = ask("  Type resource name (like 'Admin')")
  @model = singularized_and_capitalized(@model_original)
  @resources = pluralized_and_downcased(@model_original)
  @columns = ask("  If you need, type column names for #{@model} model (like 'nick_name description:text')")
end

# about omniauth
@using_omniauth = true if @using_devise && yes?('use omniauth?([yes or ELSE])')
if @using_omniauth
  @parent_original = ask("  Type parent model name you generated in above process (type like 'user')")
  @parent_model = singularized_and_capitalized(@parent_original)
  @parent_model_pluralized = pluralized_and_capitalized(@parent_original)
  @parent_model_downcased = singularized_and_downcased(@parent_original)
  @parent_resources = pluralized_and_downcased(@parent_original)
  if @parent_model == @model
    @parent_model_exists = true
  else
    @parent_columns = ask("  If you need, type column names for #{@parent_model} model (like 'nick_name description:text')")
  end
  @oauth_with_facebook = true if yes?('oauth with facebook?([yes or ELSE])')
  @oauth_with_twitter = true if yes?('oauth with twitter?([yes or ELSE])')
end

# about background jobs
@using_background = true if yes?('Use background jobs?([yes or ELSE])')
@hide_dashboard = true if @using_background && yes?('Hide dashboard from unauthorized users? ([yes or ELSE])')
@namespace = ask("Specify namespace like 'admin'") if @hide_dashboard

# about paperclip
@using_paperclip = true if @using_background && yes?('Use paperclip?([yes or ELSE])')
@add_paperclip_now = true if @using_paperclip && yes?('Add paperclip right now?([yes or ELSE])')
if @add_paperclip_now
  @paperclip_model_original = ask("  Type model name")
  @paperclip_model = singularized_and_capitalized(@paperclip_model_original)
  @paperclip_model_downcased = singularized_and_downcased(@paperclip_model_original)
  @paperclip_resources = pluralized_and_downcased(@paperclip_model_original)
  @paperclip_column = singularized_and_downcased(ask("  Type column name like 'image', 'avatar' or something"))
end

# about development flow
@using_circleci = true if yes?('Use circle ci?([yes or ELSE])')
@ruby_version = ask('Ruby version? (specify like "2.3.0")') if @using_circleci
@using_codeclimate = true if yes?('Use codeclimate?([yes or ELSE])')
