class NotifyMnosJob < ApplicationJob
  queue_as :default

  def perform
    MobileNetwork
      .joins(:extra_mobile_data_requests)
      .where(extra_mobile_data_requests: { status: %w[requested] })
      .where('extra_mobile_data_requests.created_at > ?', since_last_email)
      .having('COUNT(mobile_networks.id) > 0')
      .group('mobile_networks.id').each do |mno|
      number_of_new_requests = mno.extra_mobile_data_requests.requested.where('created_at > ?', since_last_email).count
      mno.users.each do |user|
        MnoMailer.notify_new_requests(user: user, number_of_new_requests: number_of_new_requests).deliver_now
      end
    end
  end

private

  def since_last_email
    now = Time.zone.now

    if now.monday?
      now - 72.hours
    else
      now - 24.hours
    end
  end
end
