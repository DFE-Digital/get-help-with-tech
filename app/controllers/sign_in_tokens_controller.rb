class SignInTokensController < ApplicationController
  def new
    @sign_in_token_form = SignInTokenForm.new
    if FeatureFlag.active?(:public_account_creation)
      render :sign_in_or_create_account
    else
      render :sign_in_only
    end
  end

  def validate
    @user = SessionService.validate_token!(token: params[:token], identifier: params[:identifier])
    save_user_to_session!
    flash.notice = "Welcome, #{@user.full_name}"
    redirect_to root_url_for(@user)
  rescue ArgumentError
    @sign_in_token_form = SignInTokenForm.new(token: params[:token], identifier: params[:identifier])
    render :token_not_recognised, status: :bad_request
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

    if @sign_in_token_form.valid?
      token = if @sign_in_token_form.email_is_user?
                SessionService.send_magic_link_email!(@sign_in_token_form.email_address)
              else
                SecureRandom.uuid
              end
      redirect_to sent_token_path(token: token) and return
    else
      render :new
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
    elsif user.is_dfe? && FeatureFlag.active?(:dfe_admin_ui)
      admin_path
    else
      '/'
    end
  end
end
