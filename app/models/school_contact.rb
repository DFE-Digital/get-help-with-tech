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

  def to_user
    User.new(
      schools: [school],
      full_name: full_name,
      email_address: email_address,
      telephone: phone_number,
      orders_devices: true,
    )
  end
end
