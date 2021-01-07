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
    school = School.new(staged_school.staged_attributes)
    school.save!

    unless school.responsible_body.who_will_order_devices.nil?
      school.create_preorder_information!(who_will_order_devices: school.responsible_body.who_will_order_devices.singularize)
      school.device_allocations.create!(device_type: 'std_device', allocation: 0)
    end
    school
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

private

  def update_school(staged_school)
    staged_school.counterpart_school.update!(staged_school.staged_attributes)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end
end
