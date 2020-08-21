class SchoolContact < ApplicationRecord
  belongs_to :school, inverse_of: :contacts

  enum role: {
    headteacher: 'headteacher',
    contact: 'contact',
  }

  validates :email_address, presence: true
  validates :email_address, uniqueness: { scope: :school_id }
  validates :full_name, presence: true
  validates :role, presence: true
end
