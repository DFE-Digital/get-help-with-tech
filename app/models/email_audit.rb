class EmailAudit < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true

  validates :message_type, presence: true

  scope :sent_to, ->(email_address) { where(email_address:) }

  scope :problematic, -> { where.not(govuk_notify_status: 'delivered') }
end
