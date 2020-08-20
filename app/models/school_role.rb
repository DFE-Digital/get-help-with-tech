class SchoolRole < ApplicationRecord
  belongs_to :school, inverse_of: :roles
  belongs_to :user, inverse_of: :roles

  enum role: {
    headteacher: 'headteacher',
    contact: 'contact',
  }

  validates :role, presence: true
end
