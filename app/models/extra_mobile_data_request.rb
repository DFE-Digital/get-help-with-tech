class ExtraMobileDataRequest < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :mobile_network

  validates :status, presence: true
  validates :account_holder_name, presence: true
  validates :device_phone_number, presence: true, format: { with: /\A07(\s*\d){9}\s*\z/ }
  # we have to validate on _id so that the govuk_error_summary component renders & links the error to the field correctly
  validates :mobile_network_id, presence: true
  validates :agrees_with_privacy_statement, inclusion: { in: [true] }

  enum status: {
    requested: 'requested',
    in_progress: 'in_progress',
    queried: 'queried',
    complete: 'complete',
    cancelled: 'cancelled',
  }

  # These codes were worked out by the NHSx team & the MNOs,
  # during their previous work to support NHS workers.
  # If/when we add file import back from the MNOs, we'll probably
  # need to reference the numeric codes:
  #
  # code|problem
  # ---|--------
  # 001|incorrect_phone_number
  # 002|no_match_for_number
  # 003|no_match_for_account_name
  # 006|not_eligible
  # 007|no_longer_on_network
  #
  # The discontinuity from 003-006 is because codes 004 & 005
  # are about mismatches on address / postcode, which we're not
  # supplying
  #
  # Having said all that, we're actually storing the string keys
  # for better comprehensibility
  enum problem: {
    incorrect_phone_number: 'incorrect_phone_number',
    no_match_for_number: 'no_match_for_number',
    no_match_for_account_name: 'no_match_for_account_name',
    not_eligible: 'not_eligible',
    no_longer_on_network: 'no_longer_on_network',
  }

  include ExportableAsCsv

  def self.exportable_attributes
    {
      id: 'ID',
      account_holder_name: 'Account holder name',
      device_phone_number: 'Device phone number',
      created_at: 'Requested',
      updated_at: 'Last updated',
      mobile_network_id: 'Mobile network ID',
      status: 'Status',
    }
  end

  def self.from_approved_users
    joins(:created_by_user).merge(User.approved)
  end

  def self.on_mobile_network(mobile_network_id)
    where(mobile_network_id: mobile_network_id)
  end

  def notify_account_holder_now
    notification.deliver_now
  end

  def notify_account_holder_later
    notification.deliver_later
  end

private

  def notification
    @notification ||= ExtraMobileDataRequestAccountHolderNotification.new(self)
  end
end
