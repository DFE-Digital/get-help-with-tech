class EventNotificationsService
  class << self
    def broadcast(event)
      log(event)
      send_slack_notification(event) if event.notifiable?
    end

  private

    def send_slack_notification(event)
      SlackMessage.new(
        text: format_message(event),
      ).send_later
    end

    def format_message(event)
      "[#{event.class.name}] #{event.message}"
    end

    def log(event)
      logger.info("EventNotification: #{event.class.name} \n#{event.message}")
    end

    def logger
      @logger || Rails.logger
    end
  end
end
