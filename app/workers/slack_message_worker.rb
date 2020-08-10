class SlackMessageWorker
  include Sidekiq::Worker

  def perform( channel, text, icon_emoji = nil, mrkdwn = nil, username = nil, webhook_url = nil )
    msg = SlackMessage.new( channel: channel,
                            text: text,
                            icon_emoji: icon_emoji,
                            mrkdwn: mrkdwn,
                            username: username,
                            webhook_url: webhook_url,
                          )
    msg.send_now!
  end
end
