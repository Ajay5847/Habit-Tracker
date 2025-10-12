class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    render "dashboard/index"
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)
    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      resource.errors.add(:base, t("devise.failure.invalid", authentication_keys: "email"))

      respond_to do |format|
        format.html { render "dashboard/index", status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash_messages",
            partial: "shared/flash_message",
            locals: {
              type: "error",
              message: resource.errors.full_messages.join("</br> ").html_safe
            }
          )
        end
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
