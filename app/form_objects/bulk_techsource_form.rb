class BulkTechsourceForm
  include ActiveModel::Model

  attr_accessor :emails

  validates :emails, presence: true
  validate :validate_one_email_per_line

  def array_of_emails
    emails.split("\r\n").map(&:strip).reject(&:blank?)
  end

private

  def validate_one_email_per_line
    unless emails.split("\r\n").map(&:strip).reject(&:blank?).all? { |line| line.match(/.*@.*\..*/) && !line.match(/,| /) }
      errors.add(:emails, 'must only have one email per line')
    end
  end
end
