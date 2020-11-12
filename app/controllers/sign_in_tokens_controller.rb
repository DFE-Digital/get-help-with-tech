class SignInTokensController < ApplicationController
  def new
    if SessionService.is_signed_in?(session) && @user
      redirect_to root_url_for(@user)
    else
      @sign_in_token_form ||= SignInTokenForm.new
      render :sign_in_only
    end
  end

  # GET /token/validate
  # This does NOT sign the user in, but validates the token and renders a
  # form with hidden fields that they must submit to actually sign-in
  # We do it this way because we have found many users are hitting this page
  # multiple times from different IPs, almost simultaneously - which implies
  # that it's some automatic email link-scanning security software.
  def validate
    validate_token_and do
      render :click_to_sign_in
    end
  end

  def destroy
    validate_token_and do
      save_user_to_session!
      EventNotificationsService.broadcast(SignInEvent.new(user: @user))
      @user.clear_token!

      if session['return_url'].present?
        redirect_to session['return_url']
        session.delete('return_url')
      else
        redirect_to root_url_for(@user)
      end
    end
  end

  def validate_manual
    redirect_to validate_sign_in_token_path(token: sign_in_token_form_params[:token], identifier: sign_in_token_form_params[:identifier])
  end

  def create
    @sign_in_token_form = SignInTokenForm.new(sign_in_token_form_params)

    new and return unless @sign_in_token_form.valid?

    if @sign_in_token_form.email_is_user?
      token = SessionService.send_magic_link_email!(@sign_in_token_form.email_address)
      redirect_to sent_token_path(token: token)
    else
      redirect_to email_not_recognised_path
    end
  end

  def sent
    @user = User.where(sign_in_token: params[:token]).first
  end

  def hide_nav_menu?
    action_name == 'validate' || action_name == 'sent'
  end

private

  # if the token is valid, yield to the given block
  # if not, handle appropriately
  def validate_token_and
    @user = SessionService.validate_token!(token: params[:token], identifier: params[:identifier])
    yield
  rescue SessionService::TokenValidButExpired
    # If it's the same user who already has a valid session, and they've just
    # re-clicked a link with a token that's expired, but a session that _hasn't_
    if SessionService.is_signed_in?(session) && @user.id == session[:user_id]
      # - that's ok, we'll allow it
      yield
    else
      render :token_is_valid_but_expired, status: :bad_request
    end
  rescue SessionService::TokenNotRecognised, SessionService::InvalidTokenAndIdentifierCombination
    render :token_not_recognised, status: :bad_request
  end

  def sign_in_token_form_params
    params.require(:sign_in_token_form).permit(
      :email_address,
      :token,
      :identifier,
    )
  end
end
