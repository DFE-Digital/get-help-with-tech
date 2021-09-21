class ChangeSchoolResponsibleBodyService
  attr_reader :school, :initial_rb, :new_rb

  COMPUTACENTER_CHANGE_STATUS = 'amended'.freeze

  def initialize(school, new_rb)
    @school = school
    @initial_rb = school.responsible_body
    @new_rb = new_rb
  end

  def call
    school.transaction do
      set_school_new_rb!
      add_school_to_new_pool! ? initial_rb.calculate_virtual_caps! : remove_school_from_current_pool!
      true
    end
  rescue StandardError => e
    log_error(e)
    false
  end

private

  def add_school_to_new_pool!
    AddSchoolToVirtualCapPoolService.new(school).call
  end

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  def remove_school_from_current_pool!
    RemoveSchoolFromVirtualCapPoolService.new(school, initial_rb).call || school.reload.refresh_device_ordering_status!
  end

  def set_school_new_rb!
    school.update!(
      responsible_body_id: new_rb.id,
      computacenter_change: COMPUTACENTER_CHANGE_STATUS,
    )
  end
end
