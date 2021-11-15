class Support::School::ChangeResponsibleBodyForm
  include ActiveModel::Model

  attr_accessor :school
  attr_writer :responsible_body_id, :responsible_body

  COMPUTACENTER_CHANGE_STATUS = 'amended'.freeze
  DEVICE_TYPES = %i[laptop router].freeze

  validates :school, presence: true
  validates :responsible_body, presence: true

  def responsible_body_id
    @responsible_body_id || school&.responsible_body_id
  end

  def responsible_body
    @responsible_body ||= ResponsibleBody.find_by_id(responsible_body_id)
  end

  def responsible_body_options
    @responsible_body_options ||= responsible_bodies.map do |id, name|
      OpenStruct.new(id: id, name: name)
    end
  end

  def save
    valid? && (same_responsible_body? || responsible_body_changed?)
  end

private

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  def notify_other_agents
    device_types = DEVICE_TYPES.reject { |device_type| pool_notified_agents?(device_type) }
    CapUpdateNotificationsService.new(school,
                                      device_types: device_types,
                                      notify_computacenter: false,
                                      notify_school: false).call
  end

  def pool_notified_agents?(device_type)
    return false unless school.in_virtual_cap_pool?

    school.raw_devices_ordered(device_type).positive? || school.raw_cap(device_type).positive?
  end

  def recompute_pool(responsible_body = school.responsible_body)
    responsible_body.calculate_vcaps! if responsible_body.vcap_feature_flag?
  end

  def responsible_bodies
    ResponsibleBody.gias_status_open.order(type: :asc, name: :asc).pluck(:id, :name)
  end

  def responsible_body_changed?
    school.transaction do
      original_pool = school.responsible_body if school.in_virtual_cap_pool?
      set_school_new_rb!
      recompute_pool(original_pool) if original_pool
      recompute_pool if school.in_virtual_cap_pool?
      notify_other_agents
      school.refresh_preorder_status!
      true
    end
  rescue StandardError => e
    log_error(e)
    false
  end

  def same_responsible_body?
    responsible_body_id == school.responsible_body_id
  end

  def set_school_new_rb!
    school.update!(responsible_body_id: responsible_body_id, computacenter_change: COMPUTACENTER_CHANGE_STATUS)
  end
end
