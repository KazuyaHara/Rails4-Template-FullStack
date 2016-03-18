# copied base file
copy_static_file "app/models/concerns/devise_sanitizer.rb"
remove_file "app/models/concerns/.keep"
puts "\n"

# need two sanitizers for omniauth model & paperclip model
if @using_omniauth && @using_paperclip && (@parent_model != @paperclip_model)
  puts "Updating strong paramater for #{@parent_model} & #{@paperclip_model} ..."

  # update for omniauth model
  gsub_file "app/models/concerns/devise_sanitizer.rb", /User::ParameterSanitizer/, "#{@parent_model}::ParameterSanitizer"

  # add description for paperclip model
  @paperclip_permit = "default_paramiters.permit(:#{@paperclip_column})"
  insert_into_file "app/models/concerns/devise_sanitizer.rb",%(
  class #{@paperclip_model}::ParameterSanitizer < Devise::ParameterSanitizer
    def sign_in
      # default_paramiters.permit(:email)
    end

    def sign_up
      # default_paramiters.permit(:email)
    end

    def account_update
      #{@paperclip_permit}
    end
  end
  ), before: "class #{@parent_model}::ParameterSanitizer < Devise::ParameterSanitizer"

  # add sanitizer to application_controller
  @strong_paramater_for_omniauth = "#{@parent_model}::ParameterSanitizer.new(#{@parent_model}, :#{@parent_model_downcased}, params)"
  @strong_paramater_for_paperclip = "#{@paperclip_model}::ParameterSanitizer.new(#{@paperclip_model}, :#{@paperclip_model_downcased}, params)"
  insert_into_file "app/controllers/application_controller.rb",%(

  protected
    def devise_parameter_sanitizer
      if resource_class == #{@parent_model}
        #{@strong_paramater_for_omniauth}
      elsif resource_class == #{@paperclip_model}
        #{@strong_paramater_for_paperclip}
      else
        super
      end
    end), after: 'protect_from_forgery with: :exception'
  puts "\n"

# need one sanitizer for omniauth model
elsif (@using_omniauth && @using_paperclip && (@parent_model == @paperclip_model)) || (@using_omniauth && !@using_paperclip)
  puts "Updating strong paramater for #{@parent_model} ..."

  # update for omniauth model
  gsub_file "app/models/concerns/devise_sanitizer.rb", /User::ParameterSanitizer/, "#{@parent_model}::ParameterSanitizer"

  # add sanitizer to application_controller
  @strong_paramater_for_omniauth = "#{@parent_model}::ParameterSanitizer.new(#{@parent_model}, :#{@parent_model_downcased}, params)"
  insert_into_file "app/controllers/application_controller.rb",%(

  protected
    def devise_parameter_sanitizer
      if resource_class == #{@parent_model}
        #{@strong_paramater_for_omniauth}
      else
        super
      end
    end), after: 'protect_from_forgery with: :exception'
  puts "\n"

# need one sanitizer for paperclip_model
elsif !@using_omniauth && @using_paperclip
  puts "Updating strong paramater for #{@paperclip_model} ..."

  # update for paperclip model
  gsub_file "app/models/concerns/devise_sanitizer.rb", /User::ParameterSanitizer/, "#{@paperclip_model}::ParameterSanitizer"
  gsub_file "app/models/concerns/devise_sanitizer.rb", "default_paramiters.permit(:dummy_email)", "default_paramiters.permit(:#{@paperclip_column})"

  # add sanitizer to application_controller
  @strong_paramater_for_paperclip = "#{@paperclip_model}::ParameterSanitizer.new(#{@paperclip_model}, :#{@paperclip_model_downcased}, params)"
  insert_into_file "app/controllers/application_controller.rb",%(

  protected
    def devise_parameter_sanitizer
      if resource_class == #{@paperclip_model}
        #{@strong_paramater_for_paperclip}
      else
        super
      end
    end), after: 'protect_from_forgery with: :exception'
  puts "\n"

# need nothing
else
end
