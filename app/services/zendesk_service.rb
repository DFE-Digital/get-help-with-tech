class ZendeskService
  attr_accessor :ticket

  CUSTOM_FIELD_IDS = {
    contact_form: '360011490478',
    user_type: '360011798678',
    support_topics: '360011519218',
    telephone_number: '360011762698',
    user_profile_path: '360013507477',
  }.freeze

  class << self
    def send!(ticket)
      new(ticket).send!
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
        { id: CUSTOM_FIELD_IDS[:contact_form], value: 'contact_form' },
        { id: CUSTOM_FIELD_IDS[:user_type], value: ticket['user_type'] },
        { id: CUSTOM_FIELD_IDS[:support_topics], value: ticket['support_topics'] },
        { id: CUSTOM_FIELD_IDS[:telephone_number], value: ticket['telephone_number'] },
        { id: CUSTOM_FIELD_IDS[:user_profile_path], value: ticket['user_profile_path'] },
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
