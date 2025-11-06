class ApplicationController < ActionController::Base
  include DeviceFormat
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Devise: Permit additional parameters for sign up and account update if needed
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout "application"

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :email, :password, :password_confirmation ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :email, :password, :password_confirmation, :current_password ])
  end
end
