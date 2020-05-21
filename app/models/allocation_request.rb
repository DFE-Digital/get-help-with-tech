class AllocationRequest < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', foreign_key: 'created_by_user_id'
end
