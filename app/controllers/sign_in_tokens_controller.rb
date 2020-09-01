class SignInTokensController < ApplicationController
  before_action :require_sign_in!, only: :destroy

  def new
    @sign_in_token_form ||= SignInTokenForm.new
    if FeatureFlag.active?(:public_account_creation)
      render :sign_in_or_create_account
    else
      render :sign_in_only
    end
  end

  def validate
    @user = SessionService.validate_token!(token: params[:token], identifier: params[:identifier])
    save_user_to_session!
    EventNotificationsService.broadcast(SignInEvent.new(user: @user))
    render :you_are_signed_in
  rescue SessionService::TokenValidButExpired
    # If it's the same user who already has a valid session, and they've just
    # re-clicked a link with a token that's expired, but a session that _hasn't_
    if SessionService.is_signed_in?(session) && @user.id == session[:user_id]
      # - that's ok, we'll allow it
      render :you_are_signed_in
    else
      render :token_is_valid_but_expired, status: :bad_request
    end
  rescue SessionService::TokenNotRecognised, SessionService::InvalidTokenAndIdentifierCombination
    render :token_not_recognised, status: :bad_request
  end

  def destroy
    @user.clear_token!
    redirect_to root_url_for(@user)
  end

  def validate_manual
    redirect_to validate_sign_in_token_path(token: sign_in_token_form_params[:token], identifier: sign_in_token_form_params[:identifier])
  end

  def create
    @sign_in_token_form = SignInTokenForm.new(sign_in_token_form_params)
    if FeatureFlag.active?(:public_account_creation) && \
        @sign_in_token_form.already_have_account == 'no'
      redirect_to new_user_path and return
    end

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
    # NOTE: this is purely to allow us to display the link in the footer
    # REMOVE when we have emails actually being sent
    if @user
      identifier = @user.sign_in_identifier(@user.sign_in_token)
      @debug_info = {
        sign_in_token: @user.sign_in_token,
        sign_in_identifier: identifier,
        sign_in_link: validate_sign_in_token_url(token: @user.sign_in_token, identifier: identifier),
      }
    end
  end

  def hide_nav_menu?
    action_name == 'validate' || action_name == 'sent'
  end

private

  def sign_in_token_form_params
    params.require(:sign_in_token_form).permit(
      :already_have_account,
      :email_address,
      :token,
      :identifier,
    )
  end

  def root_url_for(user)
    if user.is_mno_user?
      mno_extra_mobile_data_requests_path
    elsif user.needs_to_see_privacy_notice?
      responsible_body_privacy_notice_path
    elsif user.is_responsible_body_user?
      responsible_body_home_path
    elsif user.is_school_user?
      school_home_path
    elsif user.is_computacenter?
      computacenter_home_path
    elsif user.is_support?
      support_service_performance_path
    else
      '/'
    end
  end
end
