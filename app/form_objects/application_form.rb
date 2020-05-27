class ApplicationForm
  include ActiveModel::Model
  include InlineUser

  attr_accessor :full_name,
                :address,
                :postcode,
                :can_access_hotspot,
                :is_account_holder,
                :account_holder_name,
                :device_phone_number,
                :phone_network_name,
                :privacy_statement_sent_to_family,
                :understands_how_pii_will_be_used,
                :recipient,
                :user

  validates :full_name, presence: { message: "Tell us the recipient's full name, like John Smith" }
  validates :address, presence: { message: "Tell us the recipient's address, not including the postcode" }
  validates :postcode, presence: { message: 'Enter a postcode, like AA1 1AA' }
  validates :can_access_hotspot, presence: { message: 'Tell us whether this young person can access a BT hotspot' }
  validates :is_account_holder, presence: { message: 'Tell us whether this young person is the account holder for the mobile device' }
  validates :account_holder_name, presence: { message: 'Tell us the full name of the account holder for the mobile device' }, if: :not_account_holder?
  validates :device_phone_number, presence: { message: 'Tell us the phone number of the mobile device' }
  validates :phone_network_name, presence: { message: 'Tell us the name of the recipients mobile network, for example BT or O2' }
  validates :privacy_statement_sent_to_family, presence: { message: 'Please confirm whether this family have received the privacy statement' }
  validates :understands_how_pii_will_be_used, presence: { message: 'Please confirm whether this family understand how their personally-identifying information will be used' }

  def initialize(user: nil, recipient: nil, params: {})
    @user = user
    @recipient = recipient
    populate_from_user! if user
    populate_from_recipient! if recipient
    populate_from_params!(params) unless params.empty?
  end

  def save!
    @user ||= construct_user
    @recipient ||= construct_recipient
    validate!
    @user.save!
    @recipient.save!
  end

  def not_account_holder?
    is_account_holder == false
  end

private

  def construct_recipient
    Recipient.new(
      created_by_user: @user,
      full_name: @full_name,
      address: @address,
      postcode: @postcode,
      can_access_hotspot: @can_access_hotspot,
      is_account_holder: @is_account_holder,
      account_holder_name: @account_holder_name,
      device_phone_number: @device_phone_number,
      phone_network_name: @phone_network_name,
      privacy_statement_sent_to_family: @privacy_statement_sent_to_family,
      understands_how_pii_will_be_used: @understands_how_pii_will_be_used,
    )
  end

  def populate_from_params!(params = {})
    @user ||= User.new
    params.each do |key, value|
      send("#{key}=", value)
    end
    @user.full_name = params[:user_name]
    @user.email_address = params[:user_email]
    @user.organisation = params[:user_organisation]

    @full_name = params[:full_name]
    @address = params[:address]
    @postcode = params[:postcode]
    @can_access_hotspot = params[:can_access_hotspot]
    @is_account_holder = params[:is_account_holder]
    @account_holder_name = params[:account_holder_name]
    @device_phone_number = params[:device_phone_number]
    @phone_network_name = params[:phone_network_name]
    @privacy_statement_sent_to_family = params[:privacy_statement_sent_to_family]
    @understands_how_pii_will_be_used = params[:understands_how_pii_will_be_used]
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
