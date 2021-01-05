class ZendeskService
  attr_accessor :ticket

  class << self
    def send!(ticket)
      ZendeskService.new(ticket).send!
    end
  end

  def initialize(ticket)
    @ticket = ticket
  end

  def send!
    ZendeskAPI::Request.create!(
      client,
      requester: { email: ticket['email_address'], name: ticket['full_name'] },
      subject: ticket['subject'],
      comment: {
        body: ticket['message'],
      },
      custom_fields: [
        { id: '360011490478', value: 'contact_form' },
        { id: '360011798678', value: ticket['user_type'] },
        { id: '360011519218', value: ticket['support_topics'] },
        { id: '360011762698', value: ticket['telephone_number'] },
      ],
    )
  end

private

  def client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = 'https://get-help-with-tech-education.zendesk.com/api/v2'
      config.username = Settings.zendesk.username
      config.token = Settings.zendesk.token
      config.retry = true

      require 'logger'
      config.logger = Logger.new('log/zendesk.log')
      config.logger.level = Logger::DEBUG
    end
  end
end
