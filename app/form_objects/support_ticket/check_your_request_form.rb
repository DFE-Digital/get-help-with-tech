class SupportTicket::CheckYourRequestForm
  include ActiveModel::Model

  attr_accessor :support_ticket

  validates :support_ticket, presence: true
end
