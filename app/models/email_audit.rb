class EmailAudit < ApplicationRecord
  validates :message_type, presence: true
  validates :template, presence: true

  scope :for_school, ->(urn) { where(school_urn: urn) }
  scope :sent_to, ->(email_address) { where(email_address: email_address) }

  def school
    School.find_by(urn: school_urn)
  end

  def user
    User.find_by(email_address: email_address)
  end
end
