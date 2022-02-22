class Support::PrivilegedUserForm
  include ActiveModel::Model

  attr_accessor :full_name, :email_address, :privileges

  validates :full_name, presence: { message: 'Enter the name of the user' }
  validates :email_address, presence: { message: 'Enter the email address of the user' },
                            format: { with: /\A.*@computacenter.com|.*@digital.education.gov.uk|.*@education.gov.uk\z/,
                                      message: 'Email address must be end with @computacenter.com, @digital.education.gov.uk or @education.gov.uk' }
  validate :validate_email_not_taken
  validate :validate_at_least_one_privilege
  validate :validate_acceptable_privileges

  def create_user!
    User.create!(full_name:, email_address:, is_support: is_support?, is_computacenter: is_computacenter?)
  end

private

  def is_support?
    privileges.include?('support')
  end

  def is_computacenter?
    privileges.include?('computacenter')
  end

  def validate_acceptable_privileges
    if privileges.union(['', 'support', 'computacenter']).size > 3
      errors.add :privileges, :inclusion, message: 'Only select from available privileges'
    end
  end

  def validate_at_least_one_privilege
    if privileges.reject(&:blank?).empty?
      errors.add :privileges, :at_least_one, message: 'Select at least one privilege to apply'
    end
  end

  def validate_email_not_taken
    if User.exists?(['lower(email_address) = ?', email_address.downcase])
      errors.add :email_address, :duplicate, message: 'This email adddress has already been taken'
    end
  end
end
