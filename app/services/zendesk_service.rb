class ZendeskService
  attr_accessor :support_ticket

  CUSTOM_FIELD_IDS = {
    contact_form: '360011490478',
    user_type: '360011798678',
    support_topics: '360011519218',
    telephone_number: '360011762698',
    user_profile_path: '360013507477',
  }.freeze

  class << self
    def send!(support_ticket)
      new(support_ticket).send!
    end
  end

  def initialize(support_ticket)
    @support_ticket = support_ticket
  end

  def send!
    ZendeskAPI::Request.create!(
      client,
      requester: { email: support_ticket.email_address, name: support_ticket.full_name },
      subject: support_ticket.subject,
      comment: {
        body: support_ticket.message,
      },
      custom_fields: [
        { id: CUSTOM_FIELD_IDS[:contact_form], value: 'contact_form' },
        { id: CUSTOM_FIELD_IDS[:user_type], value: support_ticket.user_type },
        { id: CUSTOM_FIELD_IDS[:support_topics], value: support_ticket.support_topics },
        { id: CUSTOM_FIELD_IDS[:telephone_number], value: support_ticket.telephone_number },
        { id: CUSTOM_FIELD_IDS[:user_profile_path], value: support_ticket.user_profile_path },
      ],
    )
  end

private

  def client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = Settings.zendesk.url
      config.username = Settings.zendesk.username
      config.token = Settings.zendesk.token
      config.retry = true

      require 'logger'
      config.logger = Logger.new('log/zendesk.log')
      config.logger.level = Logger::DEBUG
    end
  end
end
