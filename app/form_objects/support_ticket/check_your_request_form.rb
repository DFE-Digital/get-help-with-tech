class SupportTicket::CheckYourRequestForm
  include ActiveModel::Model

  attr_accessor :ticket

  validates :ticket, presence: true

  def create_ticket
    if Settings.zendesk&.username.present? && Settings.zendesk&.token.present?
      ticket['subject'] = build_subject
      ZendeskService.send!(ticket)
    end
  end

private

  def build_subject
    urn_or_ukprn = "(#{ticket['school_unique_id']}) " if ticket['school_unique_id'].present?

    "ONLINE FORM - #{urn_or_ukprn}#{ticket['school_name']}"
  end
end
