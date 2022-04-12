class NotifyMnosJob < ApplicationJob
  queue_as :default

  def perform
    users.each do |user|
      number_of_new_requests = user.mobile_network.extra_mobile_data_requests.new_status.where('created_at > ?', since_last_email_for_user(user)).count

      if number_of_new_requests.positive?
        MnoMailer.notify_new_requests(user:, number_of_new_requests:).deliver_now
      end
    end
  end

private

  def since_last_email_for_user(user)
    user.email_audits.where(message_type: 'notify_new_requests').last&.created_at || 72.hours.ago
  end

  def users
    @users ||= User.joins(:mobile_network)
  end
end
