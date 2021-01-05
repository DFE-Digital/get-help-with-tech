class SupportTicket::ContactDetailsForm
  include ActiveModel::Model

  attr_accessor :full_name, :email_address, :telephone_number

  validates :full_name, presence: { message: 'Enter your full name' }
  validates :email_address, presence: { message: 'Enter your email address' }
  validates :email_address, email_address: true
end
