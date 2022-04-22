class ConfirmTechsourceAccountCreatedService
  attr_reader :processed, :unprocessed

  def initialize(emails: [])
    @emails = emails
    @processed = []
    @unprocessed = []
  end

  def call
    emails.each do |email|
      user = User.find_by(email_address: email) || user_based_on_previous_email(email)

      if user
        if user.update(techsource_account_confirmed_at: Time.zone.now)
          notify_user_can_order(user)

          processed << { email: }
        else
          unprocessed << { email:, message: 'User could not be updated' }
        end
      elsif email_no_longer_computacenter_relevant(email)
        processed << { email: }
      else
        unprocessed << { email:, message: 'No user with this email found' }
      end
    end
  end

  def email_count
    processed.size + unprocessed.size
  end

private

  attr_reader :emails
  attr_writer :processed, :unprocessed

  def notify_user_can_order(user)
    # Guard against multiple updates
    return if user.previous_changes.dig('techsource_account_confirmed_at', 0).present?

    UserCanOrderDevicesNotifications.new(user:).call
  end

  def email_no_longer_computacenter_relevant(email)
    Computacenter::UserChange.order(updated_at_timestamp: :desc, created_at: :desc).find_by(original_email_address: email)&.Remove?
  end

  def user_based_on_previous_email(email)
    Computacenter::UserChange.order(updated_at_timestamp: :desc, created_at: :desc).find_by(original_email_address: email)&.user
  end
end
