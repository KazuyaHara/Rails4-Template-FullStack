class User::ParameterSanitizer < Devise::ParameterSanitizer
  def sign_in
    # default_paramiters.permit(:email)
  end

  def sign_up
    # default_paramiters.permit(:email)
  end

  def account_update
    default_paramiters.permit(:dummy_email)
  end
end
