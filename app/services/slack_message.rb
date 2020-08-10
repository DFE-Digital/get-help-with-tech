require 'http'

class SlackMessage
  attr_accessor :channel, :icon_emoji, :mrkdwn, :text, :username, :webhook_url

  def initialize(params = {})
    self.text = params[:text]
    self.channel = params[:channel] || Settings.slack.event_notifications.channel
    self.mrkdwn = params[:mrkdwn] || true
    self.icon_emoji = params[:icon_emoji]
    self.username = params[:username] || Settings.slack.event_notifications.username
    self.webhook_url = params[:webhook_url] || Settings.slack.event_notifications.webhook_url
  end

  def send_now!
    response = HTTP.post(self.webhook_url, body: payload.to_json)

    unless response.status.success?
      raise SlackMessageError, "Slack error: #{response.body}"
    end
  end

  def send_later
    SlackMessageWorker.perform_async(
      self.channel,
      self.text,
      self.icon_emoji,
      self.mrkdwn,
      self.username,
      self.webhook_url,
    )
  end

  def payload
    {
      username: self.username,
      icon_emoji: self.icon_emoji,
      channel: self.channel,
      text: self.text,
      mrkdwn: self.mrkdwn,
    }
  end

  def self.hyperlink(text, url)
    "<#{url}|#{text}>"
  end

  class SlackMessageError < StandardError; end
end
