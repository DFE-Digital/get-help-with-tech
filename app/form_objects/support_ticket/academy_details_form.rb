class SupportTicket::AcademyDetailsForm
  include ActiveModel::Model

  attr_accessor :academy_name

  validates :academy_name, presence: { message: 'Enter your academy trust name' }
end
