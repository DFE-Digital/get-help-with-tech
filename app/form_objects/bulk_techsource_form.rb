class BulkTechsourceForm
  include ActiveModel::Model

  attr_accessor :emails

  validates :emails, presence: true
  validate :validate_one_email_per_line
  validate :validate_valid_emails

  def array_of_emails
    emails.split("\r\n").map(&:strip).reject(&:blank?).map(&:downcase)
  end

private

  def validate_one_email_per_line
    unless array_of_emails.all? { |line| !line.match(/,| /) }
      errors.add(:emails, 'Enter no more than one email address per line')
    end
  end

  def validate_valid_emails
    unless array_of_emails.all? { |line| line.match(/.*@.*\..*/) }
      errors.add(:emails, 'Ensure all email addresses are valid')
    end
  end
end
