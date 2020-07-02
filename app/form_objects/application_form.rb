class ApplicationForm
  include ActiveModel::Model

  attr_accessor :account_holder_name,
                :can_access_hotspot,
                :device_phone_number,
                :mobile_network_id,
                :privacy_statement_sent_to_family,
                :understands_how_pii_will_be_used,
                :request

  validates :can_access_hotspot, presence: { message: 'Tell us whether this young person can access a BT hotspot' }
  validates :account_holder_name, presence: { message: 'Tell us the full name of the account holder for the mobile device' }
  validates :device_phone_number, presence: { message: 'Tell us the phone number of the mobile device' }
  validate  :mobile_network_exists
  validates :privacy_statement_sent_to_family, presence: { message: 'Please confirm whether this family have received the privacy statement' }
  validates :understands_how_pii_will_be_used, presence: { message: 'Please confirm whether this family understand how their personally-identifying information will be used' }

  def initialize(opts = {})
    @request = opts[:extra_mobile_data_request] || ExtraMobileDataRequest.new(opts)

    @can_access_hotspot = opts[:can_access_hotspot] || @request.can_access_hotspot
    @account_holder_name = opts[:account_holder_name] || @request.account_holder_name
    @device_phone_number = opts[:device_phone_number] || @request.device_phone_number
    @mobile_network_id = opts[:mobile_network_id] || @request.mobile_network_id
    @privacy_statement_sent_to_family = opts[:privacy_statement_sent_to_family] || @request.privacy_statement_sent_to_family
    @understands_how_pii_will_be_used = opts[:understands_how_pii_will_be_used] || @request.understands_how_pii_will_be_used
  end

  def save!
    @request ||= construct_request
    validate!
    @request.status ||= ExtraMobileDataRequest.statuses[:requested]
    @request.save!
  end

private

  def mobile_network_exists
    errors.add(:mobile_network_id, 'Please select a mobile network') unless MobileNetwork.where(id: @mobile_network_id).exists?
  end

  def construct_request
    ExtraMobileDataRequest.new(
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
