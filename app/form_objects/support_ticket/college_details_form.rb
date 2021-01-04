class SupportTicket::CollegeDetailsForm
  include ActiveModel::Model

  attr_accessor :college_name, :college_ukprn

  validates :college_name, presence: { message: 'Enter your college name' }
  validates :college_ukprn, presence: { message: 'Enter your college UKPRN' }
end
