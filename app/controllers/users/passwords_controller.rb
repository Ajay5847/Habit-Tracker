class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  def new
    self.resource = resource_class.new
    render "dashboard/index"
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_to do |format|
        format.html { redirect_to new_session_path(resource_name), notice: "Reset password instructions sent." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash_messages",
            partial: "shared/flash_message",
            locals: { type: "notice", message: "Reset password instructions sent to #{resource.email}." }
          )
        end
      end
    else
      respond_to do |format|
        format.html { render "dashboard/index", status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash_messages",
            partial: "shared/flash_message",
            locals: { type: "error", message: resource.errors.full_messages.join("<br>").html_safe }
          )
        end
      end
    end
  end
end
