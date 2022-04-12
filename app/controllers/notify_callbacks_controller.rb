class NotifyCallbacksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :check_bearer_token

  def create
    return unless callback_notification_type_is_email?
    return unless user

    if existing_audit
      existing_audit.update!(govuk_notify_status: callback_params[:status])
    else
      EmailAudit.create!(
        user:,
        email_address: callback_params[:to],
        govuk_notify_id: callback_params[:id],
        govuk_notify_status: callback_params[:status],
        message_type: 'other',
      )
    end
  end

private

  def check_bearer_token
    authenticate_or_request_with_http_token do |token, _options|
      Digest::SHA256.hexdigest(token) == Settings.govuk_notify.callback_bearer_token
    end
  end

  def existing_audit
    @existing_audit ||= EmailAudit.find_by(govuk_notify_id: callback_params[:id])
  end

  def user
    @user ||= User.find_by(email_address: callback_params[:to])
  end

  def callback_params
    params.permit(:id, :reference, :status, :notification_type, :to)
  end

  def callback_notification_type_is_email?
    params[:notification_type] == 'email'
  end
end
