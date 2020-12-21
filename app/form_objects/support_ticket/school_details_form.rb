class SupportTicket::SchoolDetailsForm
  include ActiveModel::Model

  attr_accessor :school_name, :school_urn

  validates :school_name, presence: { message: 'Enter your school name' }
  validates :school_urn, presence: { message: 'Enter your school URN' }
  validates :school_urn, format: { with: /\A\d{6}\z/, message: 'The school URN must be 6 digits' }
end
