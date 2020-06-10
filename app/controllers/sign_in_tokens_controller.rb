class SignInTokensController < ApplicationController
  def new
    @sign_in_token_form = SignInTokenForm.new
  end

  def validate
    @user = SessionService.validate_token!(token: params[:token], identifier: params[:identifier])
    save_user_to_session!
    flash.notice = "Welcome, #{@user.full_name}"
    redirect_to '/'
  rescue ArgumentError
    @sign_in_token_form = SignInTokenForm.new(token: params[:token], identifier: params[:identifier])
    render :token_not_recognised, status: :bad_request
  end

  def manual
    redirect_to validate_sign_in_token_path(token: sign_in_token_form_params[:token], identifier: sign_in_token_form_params[:identifier])
  end

  def create
    @sign_in_token_form = SignInTokenForm.new(sign_in_token_form_params)

    if @sign_in_token_form.valid? && @sign_in_token_form.email_is_user?
      token = SessionService.send_magic_link_email!(@sign_in_token_form.email_address)
      # NOTE: this is purely to allow us to display the link in the footer
      # REMOVE when we have emails actually being sent
      identifier = User.where(sign_in_token: token).first.try(:sign_in_identifier, token)
      @debug_info = {
        sign_in_token: token,
        sign_in_identifier: identifier,
        sign_in_link: validate_sign_in_token_url(token: token, identifier: identifier),
      }
    end
  end

private

  def sign_in_token_form_params
    params.require(:sign_in_token_form).permit(
      :email_address,
      :token,
      :identifier,
    )
  end
end
