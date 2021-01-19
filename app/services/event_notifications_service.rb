class EventNotificationsService
  class << self
    def broadcast(event)
      log(event)
    end

  private

    def format_message(event)
      "[#{event.class.name.demodulize.underscore.humanize}] #{event.message}"
    end

    def log(event)
      logger.info("EventNotification: #{event.class.name} \n#{event.message}")
    end

    def logger
      @logger || Rails.logger
    end
  end
end
