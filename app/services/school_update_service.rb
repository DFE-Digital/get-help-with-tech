class SchoolUpdateService
  RB_NAME_MAP = {
    'Bristol, City of' => 'City of Bristol',
    'Dorset' => 'Dorset Council',
    'Herefordshire, County of' => 'Herefordshire',
    'Kingston upon Hull, City of' => 'Kingston upon Hull',
  }.freeze

  def update_schools
    # look at the schools that have changed since the last update
    last_update = Staging::DataUpdateRecord.last_update_for(:schools)

    # simple updates for schools that are open
    Staging::School.updated_since(last_update).open.each do |staged_school|
      school = School.find_by(urn: staged_school.urn)
      if school
        update_school(school, staged_school)
      else
        create_school(staged_school)
      end
    end

    Staging::DataUpdateRecord.updated!(:schools)
  end

private

  def update_school(school, staged_school)
    # update school details
    attrs = staged_attributes(staged_school)
    school.update!(attrs)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def create_school(staged_school)
    School.create!(staged_attributes(staged_school))
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end

  def staged_attributes(staged_school)
    attrs = staged_school.attributes.except('id', 'responsible_body_name', 'status', 'created_at', 'updated_at')
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
