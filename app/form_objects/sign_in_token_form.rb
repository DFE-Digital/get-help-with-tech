class SignInTokenForm
  include ActiveModel::Model

  attr_accessor :email_address, :token, :identifier

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def email_is_user?
    User.where(email_address: @email_address).exists?
  end
end
