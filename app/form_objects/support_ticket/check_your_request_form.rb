class SupportTicket::CheckYourRequestForm
  include ActiveModel::Model

  attr_accessor :ticket

  validates :ticket, presence: true

  def create_ticket
    ticket['subject'] = "TESTING - (#{ticket['school_unique_id']}) #{ticket['school_name']} "
    ZendeskService.send!(ticket)
  end
end
