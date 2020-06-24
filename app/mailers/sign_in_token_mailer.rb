class SignInTokenMailer < ApplicationMailer
  DEFAULT_NOTIFY_TEMPLATE_ID = '89b4abbb-0f01-4546-bf30-f88db5e0ae3c'.freeze

  def sign_in_token_email
    @user = params[:user]
    identifier = @user.sign_in_identifier(@user.sign_in_token)

    personalisation = {
      to: @user.email_address,
      token_url: url(:validate_sign_in_token_url, token: @user.sign_in_token, identifier: identifier),
      token_expires_at: I18n.l(@user.sign_in_token_expires_at, format: :time_only),
      sign_in_link: url(:sign_in_url),
    }

    template_mail(
      notify_template_id,
      to: @user.email_address,
      personalisation: personalisation,
    )
  end

private

  def notify_template_id
    ENV.fetch('SIGN_IN_TOKEN_MAIL_NOTIFY_TEMPLATE_ID', DEFAULT_NOTIFY_TEMPLATE_ID)
  end
end
