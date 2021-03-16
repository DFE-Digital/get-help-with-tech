class EmailAudit < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true

  validates :message_type, presence: true

  scope :sent_to, ->(email_address) { where(email_address: email_address) }

  scope :problematic, -> { where(govuk_notify_status: %w[permanent-failure temporary-failure technical-failure]) }
end
