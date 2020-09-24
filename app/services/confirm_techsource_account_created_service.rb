class ConfirmTechsourceAccountCreatedService
  attr_reader :processed, :unprocessed

  def initialize(emails: [])
    @emails = emails
    @processed = []
    @unprocessed = []
  end

  def call
    emails.each do |email|
      user = User.find_by(email_address: email)

      if user
        if user.update(has_techsource_account: true)
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
