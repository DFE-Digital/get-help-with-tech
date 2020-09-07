class SchoolContact < ApplicationRecord
  belongs_to :school, inverse_of: :contacts

  enum role: {
    headteacher: 'headteacher',
    contact: 'contact',
  }

  validates :email_address,
            presence: true,
            uniqueness: { scope: :school_id },
            email_address: true

  validates :full_name, presence: true
  validates :role, presence: true
end
