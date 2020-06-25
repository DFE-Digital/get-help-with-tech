class ApplicationForm
  include ActiveModel::Model

  attr_accessor :account_holder_name,
                :can_access_hotspot,
                :device_phone_number,
                :mobile_network_id,
                :privacy_statement_sent_to_family,
                :understands_how_pii_will_be_used,
                :recipient

  validates :can_access_hotspot, presence: { message: 'Tell us whether this young person can access a BT hotspot' }
  validates :account_holder_name, presence: { message: 'Tell us the full name of the account holder for the mobile device' }
  validates :device_phone_number, presence: { message: 'Tell us the phone number of the mobile device' }
  validate  :mobile_network_exists
  validates :privacy_statement_sent_to_family, presence: { message: 'Please confirm whether this family have received the privacy statement' }
  validates :understands_how_pii_will_be_used, presence: { message: 'Please confirm whether this family understand how their personally-identifying information will be used' }

  def initialize(opts = {})
    @recipient = opts[:recipient] || Recipient.new(opts)

    @can_access_hotspot = opts[:can_access_hotspot] || @recipient.can_access_hotspot
    @account_holder_name = opts[:account_holder_name] || @recipient.account_holder_name
    @device_phone_number = opts[:device_phone_number] || @recipient.device_phone_number
    @mobile_network_id = opts[:mobile_network_id] || @recipient.mobile_network_id
    @privacy_statement_sent_to_family = opts[:privacy_statement_sent_to_family] || @recipient.privacy_statement_sent_to_family
    @understands_how_pii_will_be_used = opts[:understands_how_pii_will_be_used] || @recipient.understands_how_pii_will_be_used
  end

  def save!
    @recipient ||= construct_recipient
    validate!
    @recipient.status ||= Recipient.statuses[:requested]
    @recipient.save!
  end

private

  def mobile_network_exists
    errors.add(:mobile_network_id, 'Please select a mobile network') unless MobileNetwork.where(id: @mobile_network_id).exists?
  end

  def construct_recipient
    Recipient.new(
      can_access_hotspot: @can_access_hotspot,
      is_account_holder: @is_account_holder,
      account_holder_name: @account_holder_name,
      device_phone_number: @device_phone_number,
      phone_network_name: @phone_network_name,
      mobile_network_id: @mobile_network_id,
      privacy_statement_sent_to_family: @privacy_statement_sent_to_family,
      understands_how_pii_will_be_used: @understands_how_pii_will_be_used,
    )
  end
end
