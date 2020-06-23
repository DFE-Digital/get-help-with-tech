class User < ApplicationRecord
  has_many :allocation_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user, dependent: :destroy
  belongs_to :mobile_network, optional: true

  validates :full_name, presence: { message: 'Enter your full name' },
                        length: { minimum: 2, maximum: 1024 }

  validates :email_address, presence: { message: 'Enter an email address in the correct format, like name@example.com' },
                            uniqueness: { message: 'Email address has already been used'},
                            length: { minimum: 2, maximum: 1024 }

  validates :organisation, presence: { message: 'Enter the name of the organisation you work for' },
                           length: { minimum: 2, maximum: 1024 }

  include SignInWithToken

  def is_mno_user?
    mobile_network.present?
  end

  def is_dfe?
    email_address.present? && email_address.match?(/[\.@]education.gov.uk$/)
  end
end
