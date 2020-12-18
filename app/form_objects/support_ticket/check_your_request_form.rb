class SupportTicket::CheckYourRequestForm
  include ActiveModel::Model

  attr_accessor :ticket

  validates :ticket, presence: true

  def create_ticket
    if Settings.zendesk.present? && Settings.zendesk.username.present? && Settings.zendesk.token.present?
      ticket['subject'] = "TESTING - (#{ticket['school_unique_id']}) #{ticket['school_name']} "
      ZendeskService.send!(ticket)
    end
  end
end
