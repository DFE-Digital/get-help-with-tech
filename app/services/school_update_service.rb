class SchoolUpdateService
  def update_schools
    # look at the schools that have changed since the last update
    last_update = DataStage::DataUpdateRecord.last_update_for(:schools)

    # attribute updates for schools
    DataStage::School.updated_since(last_update).find_each(batch_size: 100) do |staged_school|
      update_school(staged_school) if staged_school.counterpart_school.present?
    end

    DataStage::DataUpdateRecord.updated!(:schools)
  end

  def create_school(staged_school)
    Rails.logger.info("Adding school #{staged_school.urn} #{staged_school.name} (#{staged_school.status})")
    school = School.create!(staged_school.staged_attributes)
    unless school.responsible_body.who_will_order_devices.nil?
      school.create_preorder_information!(who_will_order_devices: school.responsible_body.who_will_order_devices.singularize)
      school.device_allocations.std_device.create!(allocation: 0)
      school.device_allocations.coms_device.create!(allocation: 0)
    end
    school
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def schools_that_need_to_be_added
    DataStage::School.gias_status_open.where.not(urn: School.gias_status_open.select(:urn))
  end

  def schools_that_have_changes
    []
  end

  def schools_that_need_to_be_closed
    DataStage::School.gias_status_closed.where(urn: School.gias_status_open.select(:urn))
  end

private

  def update_school(staged_school)
    staged_school.counterpart_school.update!(staged_school.staged_attributes)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end
end
