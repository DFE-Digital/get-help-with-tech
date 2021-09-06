class ChangeSchoolResponsibleBodyService
  attr_reader :school, :initial_responsible_body, :new_responsible_body

  COMPUTACENTER_CHANGE_STATUS = 'amended'.freeze

  def initialize(school, new_responsible_body)
    @school = school
    @initial_responsible_body = school.responsible_body
    @new_responsible_body = new_responsible_body
  end

  def call
    school.transaction do
      remove_school_from_current_pool if school_can_be_removed?
      set_school_new_responsible_body
      update_preorder_information
      add_school_to_new_pool if school_can_be_added?
    end
    true
  rescue StandardError => e
    log_error(e)
    false
  end

private

  def add_school_to_new_pool
    new_responsible_body.add_school_to_virtual_cap_pools!(school)
  end

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  def remove_school_from_current_pool
    initial_responsible_body.remove_school_from_virtual_cap_pools!(school)
  end

  def school_can_be_added?
    new_responsible_body.can_school_be_added_to_virtual_cap_pools?(school)
  end

  def school_can_be_removed?
    initial_responsible_body&.can_school_be_removed_from_virtual_cap_pools?(school)
  end

  def set_school_new_responsible_body
    school.update!(
      responsible_body_id: new_responsible_body.id,
      computacenter_change: COMPUTACENTER_CHANGE_STATUS,
    )
  end

  def update_preorder_information
    school.preorder_information.refresh_status!
  end
end
