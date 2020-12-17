class SupportTicket::SupportDetailsForm
  include ActiveModel::Model

  attr_accessor :message

  validates :message, presence: { message: 'Tell us how can we help you' }
end
