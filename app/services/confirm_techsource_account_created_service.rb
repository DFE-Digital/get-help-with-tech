class ConfirmTechsourceAccountCreatedService
  attr_reader :processed, :unprocessed

  def initialize(emails: [])
    @emails = emails
    @processed = []
    @unprocessed = []
  end

  def call
    emails.each do |email|
      user = User.find_by(email_address: email) || Computacenter::UserChange.order(updated_at_timestamp: :desc).find_by(original_email_address: email).user

      if user
        if user.update(techsource_account_confirmed_at: Time.zone.now)
          processed << { email: email }
        else
          unprocessed << { email: email, message: 'User could not be updated' }
        end
      else
        unprocessed << { email: email, message: 'No user with this email found' }
      end
    end
  end

  def email_count
    processed.size + unprocessed.size
  end

private

  attr_reader :emails
  attr_writer :processed, :unprocessed
end
