class School < ApplicationRecord
  belongs_to :responsible_body

  validates :urn, presence: true
  validates :name, presence: true
end
