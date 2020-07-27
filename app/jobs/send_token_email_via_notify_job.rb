class SendTokenEmailViaNotifyJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    mail = SignInTokenMailer.with(user: user).sign_in_token_email
    mail.deliver!
  end
end
