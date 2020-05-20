class ApplicationForm
  include ActiveModel::Model

  attr_accessor :user_id, :user_name, :user_email, :user_organisation
  attr_accessor :full_name,
                :address,
                :postcode,
                :can_access_hotspot,
                :is_account_holder,
                :account_holder_name,
                :device_phone_number,
                :phone_network_name,
                :privacy_statement_sent_to_family,
                :understands_how_pii_will_be_used

  validates_presence_of :user_name, :user_email, :user_organisation

  def initialize(user: nil, recipient: nil)
    @user = user || User.new
    @recipient = recipient || Recipient.new
    populate_from_user!
    populate_from_recipient!
  end

  def save!
    @user.save!
    @recipient.save!
  end

private

  def populate_from_user!
    @user_id = @user.id
    @user_name = @user.full_name
    @user_email = @user.email_address
    @user_organisation = @user.organisation
  end

  def populate_from_recipient!
    @full_name = @recipient.full_name
    @address = @recipient.address
    @postcode = @recipient.postcode
    @can_access_hotspot = @recipient.can_access_hotspot
    @is_account_holder = @recipient.is_account_holder
    @account_holder_name = @recipient.account_holder_name
    @device_phone_number = @recipient.device_phone_number
    @phone_network_name = @recipient.phone_network_name
    @privacy_statement_sent_to_family = @recipient.privacy_statement_sent_to_family
    @understands_how_pii_will_be_used = @recipient.understands_how_pii_will_be_used
  end
end
