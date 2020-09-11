class UserOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, polymorphic: true
end
