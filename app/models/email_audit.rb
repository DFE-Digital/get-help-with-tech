class EmailAudit < ApplicationRecord
  belongs_to :user
  belongs_to :school

  validates :message_type, presence: true
  validates :template, presence: true

  scope :sent_to, ->(email_address) { where(email_address: email_address) }
end
