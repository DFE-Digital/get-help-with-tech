class NotifyExtraMobileDataRequestAccountHolderJob < ApplicationJob
  queue_as :default

  def perform(extra_mobile_data_request)
    ExtraMobileDataRequestAccountHolderNotification.new(extra_mobile_data_request).deliver_now
  end
end
