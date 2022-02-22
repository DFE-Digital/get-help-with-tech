class LogEmailDeliveryObserver
  def self.delivered_email(message)
    log_to_debugger(message)
    link_message_with_audit(message)
  end

  def self.log_to_debugger(message)
    Rails.logger.debug <<~END_LOG_MSG
      To: #{message.to}

      #{message.preview.try(:body)}
    END_LOG_MSG
  end

  def self.link_message_with_audit(message)
    if message.delivery_method.is_a?(Mail::Notify::DeliveryMethod)
      govuk_notify_id = message.delivery_method.response.id
      audit_id = message.delivery_method.response.reference
      audit = EmailAudit.find_by(id: audit_id)

      if audit
        audit.update!(govuk_notify_id:)
      end
    end
  rescue StandardError => e
    Rails.logger.warn(e)
    Rails.logger.warn(e.message)
  end
end
