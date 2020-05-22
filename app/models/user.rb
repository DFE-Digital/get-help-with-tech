class User < ApplicationRecord
  has_many :allocation_requests, foreign_key: :created_by_user_id, inverse_of: :created_by_user

  validates :full_name, presence: true, length: {minimum: 2, maximum: 1024}
  validates :email_address, presence: true, length: {minimum: 2, maximum: 1024}
  validates :organisation, presence: true, length: {minimum: 2, maximum: 1024}
end
