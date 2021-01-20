class ExtraMobileDataRequest < ApplicationRecord
  after_initialize :set_defaults
  before_save :normalise_device_phone_number

  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :mobile_network, optional: true # set to optional as we already validate on the presence of mobile_network_id and we don't want duplicate validation errors
  belongs_to :responsible_body, optional: true
  belongs_to :school, optional: true

  validates :status, presence: true
  validates :account_holder_name, presence: true
  validates :device_phone_number, presence: true, phone: { types: [:mobile], countries: [:gb] }, on: :create
  # we have to validate on _id so that the govuk_error_summary component renders & links the error to the field correctly
  validates :mobile_network_id, presence: true
  validates :contract_type, presence: true, on: :create
  validates :agrees_with_privacy_statement, inclusion: { in: [true] }

  validate :validate_school_or_rb_present

  enum status: {
    requested: 'requested',
    in_progress: 'in_progress',
    complete: 'complete',
    cancelled: 'cancelled',
    unavailable: 'unavailable',
    problem_no_match_for_number: 'problem_no_match_for_number',
    problem_not_eligible: 'problem_not_eligible',
    problem_incorrect_phone_number: 'problem_incorrect_phone_number',
    problem_no_match_for_account_name: 'problem_no_match_for_account_name',
    problem_no_longer_on_network: 'problem_no_longer_on_network',
  }

  scope :in_a_problem_state, -> { where('status like ?', 'problem%') }

  def self.problem_statuses
    statuses.keys.select { |k| k.start_with?('problem') }
  end

  enum contract_type: {
    pay_as_you_go_payg: 'pay_as_you_go_payg',
    pay_monthly: 'pay_monthly',
  }

  include ExportableAsCsv

  scope :from_responsible_bodies, -> { where.not(responsible_body: nil) }
  scope :from_schools, -> { where.not(school: nil) }

  def self.exportable_attributes
    {
      id: 'ID',
      account_holder_name: 'Account holder name',
      device_phone_number: 'Device phone number',
      created_at: 'Requested',
      updated_at: 'Last updated',
      mobile_network_id: 'Mobile network ID',
      status: 'Status',
      contract_type: 'Contract type',
    }
  end

  def self.on_mobile_network(mobile_network_id)
    where(mobile_network_id: mobile_network_id)
  end

  def notify_account_holder_now
    notification.deliver_now
  end

  def save_and_notify_account_holder!
    update_status_from_mobile_network_participation
    save!
    notification.deliver_later
  end

  def has_already_been_made?
    self.class.exists?(
      account_holder_name: account_holder_name,
      device_phone_number: device_phone_number,
      mobile_network_id: mobile_network_id,
    )
  end

  def in_end_state?
    complete? || cancelled?
  end

  def in_a_problem_state?
    status.start_with?('problem')
  end

private

  def validate_school_or_rb_present
    if school_id.blank? && responsible_body_id.blank?
      errors.add(:school, 'school or responsible body must be present')
      errors.add(:responsible_body, 'school or responsible body must be present')
    end
  end

  def update_status_from_mobile_network_participation
    participating = mobile_network.participating?

    if requested? && !participating
      self.status = 'unavailable'
    elsif unavailable? && participating
      self.status = 'requested'
    end
  end

  def notification
    @notification ||= ExtraMobileDataRequestAccountHolderNotification.new(self)
  end

  def normalise_device_phone_number
    self.device_phone_number = Phonelib.parse(device_phone_number).national(false).presence
  end

  def set_defaults
    self.status ||= :requested if new_record?
  end
end
