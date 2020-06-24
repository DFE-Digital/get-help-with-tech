class SignInTokenForm
  include ActiveModel::Model

  attr_accessor :email_address, :token, :identifier, :already_have_account

  validates :email_address,
            presence: { message: 'Enter an email address in the correct format, like name@example.com' },
            length: { minimum: 2, maximum: 1024, message: 'Email address must be between 2 and 1048 characters long' },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: 'Enter an email address in the correct format, like name@example.com' }

  def email_is_user?
    User.where(email_address: @email_address).exists?
  end
end
