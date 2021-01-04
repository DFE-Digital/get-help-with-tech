class SupportTicket::LocalAuthorityDetailsForm
  include ActiveModel::Model

  attr_accessor :local_authority_name

  validates :local_authority_name, presence: { message: 'Enter your local authority name' }
end
