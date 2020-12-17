class SupportTicket::SchoolDetailsForm
  include ActiveModel::Model

  attr_accessor :school_name, :school_urn

  validates :school_name, presence: { message: 'Enter your school name' }
  validates :school_urn, presence: { message: 'Enter your school URN' }
end
