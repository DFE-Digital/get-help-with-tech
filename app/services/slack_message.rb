require 'http'

class SlackMessage
  attr_accessor :channel, :mrkdwn, :text, :username, :webhook_url

  def initialize(params = {})
    self.text = params[:text]
    self.channel = params[:channel] || Settings.slack.event_notifications.channel
    self.mrkdwn = params[:mrkdwn] || true
    self.username = params[:username] || Settings.slack.event_notifications.username
    self.webhook_url = params[:webhook_url] || Settings.slack.event_notifications.webhook_url
  end

  def send_now!
    response = HTTP.post(webhook_url, body: payload.to_json)

    unless response.status.success?
      raise SlackMessageError, "Slack error: #{response.body}"
    end
  end

  def send_later
    SendSlackMessageJob.perform_later(payload)
  end

  def payload
    {
      username: username,
      channel: channel,
      text: text,
      mrkdwn: mrkdwn,
    }
  end

  def self.hyperlink(text, url)
    "<#{url}|#{text}>"
  end

  class SlackMessageError < StandardError; end
end
