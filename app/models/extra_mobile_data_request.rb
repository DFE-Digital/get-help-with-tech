class ExtraMobileDataRequest < ApplicationRecord
  has_paper_trail

  after_initialize :set_defaults
  before_validation :normalise_device_phone_number, :normalise_name, :update_hashes

  after_save :record_completion_if_needed!

  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :mobile_network, optional: true # set to optional as we already validate on the presence of mobile_network_id and we don't want duplicate validation errors
  belongs_to :responsible_body, optional: true
  belongs_to :school, optional: true

  has_many :completion_events, -> { where(event_name: 'completion').order(event_time: :asc) }, as: :record, class_name: 'ReportableEvent'

  validates :status, presence: true
  validates :account_holder_name, presence: true
  validates :device_phone_number, presence: true, phone: { types: [:mobile], countries: [:gb] }, on: :create
  # we have to validate on _id so that the govuk_error_summary component renders & links the error to the field correctly
  validates :mobile_network_id, presence: true
  validates :contract_type, presence: true, on: :create
  validates :agrees_with_privacy_statement, inclusion: { in: [true] }

  validate :validate_school_or_rb_present
  validate :validate_request_uniqueness, on: :create
  validate :validate_network_permits_fe
  validate :validate_not_example_number

  enum status: {
    new: 'new',
    in_progress: 'in_progress',
    complete: 'complete',
    cancelled: 'cancelled',
    unavailable: 'unavailable',
    problem_no_match_for_number: 'problem_no_match_for_number',
    problem_not_eligible: 'problem_not_eligible',
    problem_incorrect_phone_number: 'problem_incorrect_phone_number',
    problem_no_match_for_account_name: 'problem_no_match_for_account_name',
    problem_no_longer_on_network: 'problem_no_longer_on_network',
    problem_duplicate: 'problem_duplicate',
    problem_other: 'problem_other',
  }, _suffix: true

  scope :in_a_problem_state, -> { where('status like ?', 'problem%') }

  def self.problem_statuses
    statuses.keys.select { |k| k.start_with?('problem') }
  end

  def self.statuses_that_mno_users_can_assign
    statuses.keys - %w[new cancelled unavailable]
  end

  def self.statuses_that_mno_users_can_use_in_csv_uploads
    statuses.keys - %w[cancelled unavailable]
  end

  def self.statuses_that_school_and_rb_users_can_see
    statuses.keys - %w[cancelled]
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

  def has_already_been_made?(extra_conditions = {})
    self.class.exists?(
      {
        normalised_name: normalised_name,
        device_phone_number: device_phone_number,
        mobile_network_id: mobile_network_id,
        contract_type: contract_type,
      }.merge(extra_conditions),
    )
  end

  def in_end_state?
    complete_status? || cancelled_status?
  end

  def in_a_problem_state?
    status.start_with?('problem')
  end

  def normalise_name
    self.normalised_name = account_holder_name.to_s.downcase.gsub(/[\s[[:punct:]]]/, '')
  end

private

  def validate_not_example_number
    if device_phone_number == '07123456789'
      errors.add(:device_phone_number, '07123456789 is the example number and will not be added')
    end
  end

  def validate_network_permits_fe
    if school&.hide_mno? && MobileNetwork.excluded_fe_networks.include?(mobile_network)
      errors.add(:mobile_network, "#{mobile_network.brand} do not accept requests for students over the age of 16")
    end
  end

  def validate_school_or_rb_present
    if school_id.blank? && responsible_body_id.blank?
      errors.add(:school, 'school or responsible body must be present')
      errors.add(:responsible_body, 'school or responsible body must be present')
    end
  end

  def validate_request_uniqueness
    scope = school_id.present? ? { school_id: school_id } : { responsible_body_id: responsible_body_id }
    errors.add(:device_phone_number, :duplicate) if has_already_been_made?(scope)
  end

  def update_status_from_mobile_network_participation
    participating = mobile_network.participating?

    if new_status? && !participating
      self.status = 'unavailable'
    elsif new_status? && participating
      self.status = 'new'
    end
  end

  def notification
    @notification ||= ExtraMobileDataRequestAccountHolderNotification.new(self)
  end

  def normalise_device_phone_number
    self.device_phone_number = Phonelib.parse(device_phone_number).national(false).presence
  end

  def set_defaults
    self.status ||= :new if new_record?
  end

  def record_completion_if_needed!
    ReportableEvent.create!(record: self, event_name: 'completion') if complete_status? && saved_change_to_status?
  end

  def update_hashes
    self.hashed_account_holder_name = account_holder_name.nil? ? nil : Digest::MD5.hexdigest(account_holder_name)
    self.hashed_normalised_name = normalised_name.nil? ? nil : Digest::MD5.hexdigest(normalised_name)
    self.hashed_device_phone_number = device_phone_number.nil? ? nil : Digest::MD5.hexdigest(device_phone_number)
  end
end
