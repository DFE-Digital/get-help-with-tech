class SchoolSearchForm
  include ActiveModel::Model

  attr_accessor :search_type, :name_or_identifier, :identifier, :identifiers, :responsible_body_id, :order_state

  validates :search_type, presence: true, inclusion: { in: %w[single multiple responsible_body_or_order_state] }
  validates :identifiers, presence: true, format: { with: /\A((ISS|SCL)?\d+\s*)*\z/ }, if: ->(form) { form.search_type == 'multiple' }
  validates :name_or_identifier, presence: true, if: ->(form) { form.search_type == 'single' }
  validate :responsible_body_or_order_state_present_when_search_type_responsible_body_or_order_state
  validates :order_state, inclusion: { in: School.order_states }, allow_blank: true

  ISS_OR_SCL = /(ISS|SCL)/

  def array_of_identifiers
    @array_of_identifiers ||= identifiers.to_s.split("\r\n").map(&:strip).reject(&:blank?)
  end

  def urn_or_ukprn_identifiers
    array_of_identifiers.reject { |i| i =~ ISS_OR_SCL }
  end

  def provision_urn_identifiers
    array_of_identifiers.find_all { |i| i =~ ISS_OR_SCL }
  end

  def request_count
    array_of_identifiers.size
  end

  def missing_count
    request_count - result_count
  end

  def result_count
    schools.count
  end

  def schools
    school_records = School.includes(:responsible_body, :std_device_allocation)

    if search_type == 'single'
      school_records = school_records.matching_name_or_urn_or_ukprn_or_provision_urn(identifier.presence || name_or_identifier)
    elsif search_type == 'multiple'
      school_records = school_records.where('urn IN (?) OR ukprn in (?) OR provision_urn in (?)', urn_or_ukprn_identifiers, urn_or_ukprn_identifiers, provision_urn_identifiers) if array_of_identifiers.present?
    elsif search_type == 'responsible_body_or_order_state'
      school_records = school_records.where(responsible_body_id: responsible_body_id) if responsible_body_id.present?
      school_records = school_records.where(order_state: order_state) if order_state.present?
    else
      raise "Unexpected search type: #{search_type}"
    end

    @schools ||= school_records
  end

  def missing_identifiers
    array_of_identifiers - schools.pluck(:urn, :ukprn, :provision_urn).flatten.compact.map(&:to_s)
  end

  def select_responsible_body_options
    ResponsibleBody.order(:name).pluck(:id, :name).map { |id, name|
      OpenStruct.new(id: id, name: name)
    }.prepend(OpenStruct.new(id: nil, name: '(all)'))
  end

  def select_order_state_options
    School.translated_enum_values(:order_states).prepend(OpenStruct.new(value: nil, label: '(all)'))
  end

  def csv_filename
    tokens = %w[allocations]
    tokens << "#{array_of_identifiers.count}-URNs" if identifiers.present?
    tokens << "RB-#{responsible_body_id}" if responsible_body_id.present?
    tokens << order_state if order_state.present?
    tokens << Time.zone.now.utc.iso8601
    tokens.join('-') + '.csv'
  end

private

  def responsible_body_or_order_state_present_when_search_type_responsible_body_or_order_state
    if search_type == 'responsible_body_or_order_state' && [responsible_body_id, order_state].all?(&:blank?)
      errors.add(:search_type, :rb_or_order_state_blank)
    end
  end
end
