class SendSlackMessageJob < ApplicationJob
  queue_as :slack_messages

  def perform(args = {})
    msg = SlackMessage.new(args)
    msg.send_now!
  end
end
