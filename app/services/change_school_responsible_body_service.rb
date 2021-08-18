class ChangeSchoolResponsibleBodyService
  attr_reader :school, :new_responsible_body_id

  COMPUTACENTER_CHANGE_STATUS = 'amended'.freeze

  def initialize(school, new_responsible_body_id)
    @school = school
    @new_responsible_body_id = new_responsible_body_id
  end

  def call
    change_responsible_body!
    true
  rescue StandardError => e
    log_error(e)
    false
  end

private

  def change_responsible_body!
    school.transaction do
      update_school!
      update_preorder_information!
    end
  end

  def log_error(e)
    school.errors.add(:base, e.message)
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  def update_preorder_information!
    school.preorder_information.refresh_status!
  end

  def update_school!
    school.update!(
      responsible_body_id: new_responsible_body_id,
      computacenter_change: COMPUTACENTER_CHANGE_STATUS,
    )
  end
end
