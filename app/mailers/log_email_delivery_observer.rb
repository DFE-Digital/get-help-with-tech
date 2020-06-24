class LogEmailDeliveryObserver
  def self.delivered_email(message)
    Rails.logger.debug <<~END_LOG_MSG
      To: #{message.to}

      #{message.preview.try(:body)}
    END_LOG_MSG
  end
end
