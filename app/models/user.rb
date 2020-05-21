class User < ApplicationRecord
  has_many :allocation_requests, foreign_key: :created_by_user_id
end
