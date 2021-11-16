class SchoolSetWhoManagesOrdersService
  attr_reader :clear_preorder_information, :notify, :recalculate_vcaps, :school, :who

  DEVICE_TYPES = %i[laptop router].freeze

  def initialize(school, who, clear_preorder_information: false, recalculate_vcaps: true, notify: true)
    @clear_preorder_information = clear_preorder_information
    @notify = notify
    @recalculate_vcaps = recalculate_vcaps
    @school = school
    @who = who
  end

  def call
    school.orders_managed_by!(who, clear_preorder_information: clear_preorder_information)
    recalculate_vcaps! if recalculate_vcaps
    notify_other_agents if notify
    school.refresh_preorder_status!
    true
  rescue StandardError => e
    failed(e)
  end

private

  def failed(e)
    log_error(e)
    false
  end

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  def notify_other_agents
    device_types = DEVICE_TYPES.reject do |device_type|
      school.vcap? && school_impacts_computacenter_numbers?(device_type)
    end

    CapUpdateNotificationsService.new(school,
                                      device_types: device_types,
                                      notify_computacenter: false,
                                      notify_school: false).call
  end

  def pools_affected
    DEVICE_TYPES.select { |device_type| school_impacts_pool_numbers?(device_type) }
  end

  def recalculate_vcaps!
    pools_affected.each { |device_type| school.calculate_vcap(device_type) }
  end

  def school_impacts_computacenter_numbers?(device_type)
    school.raw_devices_ordered(device_type).positive? || school.raw_cap(device_type).positive?
  end

  def school_impacts_pool_numbers?(device_type)
    (school_impacts_computacenter_numbers?(device_type) || school.raw_allocation(device_type).positive?)
  end
end
