class SendSlackMessageJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    msg = SlackMessage.new(args)
    msg.send_now!
  end
end
