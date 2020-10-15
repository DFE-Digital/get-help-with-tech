class SchoolUpdateService
  RB_NAME_MAP = {
    'Bristol, City of' => 'City of Bristol',
    'Dorset' => 'Dorset Council',
    'Herefordshire, County of' => 'Herefordshire',
    'Kingston upon Hull, City of' => 'Kingston upon Hull',
  }.freeze

  def update_schools
    # look at the schools that have changed since the last update
    last_update = DataStage::DataUpdateRecord.last_update_for(:schools)

    # attribute updates for schools
    DataStage::School.updated_since(last_update).find_each(batch_size: 100) do |staged_school|
      school = School.find_by(urn: staged_school.urn)
      if school
        update_school(school, staged_school)
      # FIXME: for now avoid auto adding schools, just process updates
      # else
      #   create_school(staged_school)
      end
    end

    DataStage::DataUpdateRecord.updated!(:schools)
  end

private

  def update_school(school, staged_school)
    # update school details (not RB association)
    attrs = staged_attributes(staged_school)
    school.update!(attrs)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def create_school(staged_school)
    Rails.logger.info("Adding school #{staged_school.urn} #{staged_school.name} (#{staged_school.status})")
    school = School.create!(staged_attributes(staged_school))
    unless school.responsible_body.who_will_order_devices.nil?
      school.create_preorder_information!(who_will_order_devices: school.responsible_body.who_will_order_devices.singularize)
      school.device_allocations.create!(device_type: 'std_device', allocation: 0)
    end
    school
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def staged_attributes(staged_school)
    attrs = staged_school.attributes.except('id', 'responsible_body_name', 'created_at', 'updated_at')
    attrs['responsible_body_id'] = responsible_body_id(staged_school.responsible_body_name)
    attrs
  end

  def responsible_body_id(name)
    rb_id = ResponsibleBody.find_by(name: rb_name(name))&.id

    Rails.logger.error("Did not find responsible body: #{name}") unless rb_id

    rb_id
  end

  def rb_name(name)
    RB_NAME_MAP.fetch(name, name)
  end
end
