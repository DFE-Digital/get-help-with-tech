class ImportSchoolsService
  attr_reader :datasource

  RB_NAME_MAP = {
    'Bristol, City of' => 'City of Bristol',
    'Dorset' => 'Dorset Council',
    'Herefordshire, County of' => 'Herefordshire',
    'Kingston upon Hull, City of' => 'Kingston upon Hull',
  }.freeze

  def initialize(school_datasource = GetInformationAboutSchools)
    @datasource = school_datasource
  end

  def import_schools
    datasource.schools do |school_data|
      school = School.find_by(urn: school_data[:urn])
      attrs = attrs_with_responsible_body_id(school_data)

      if school
        school.update!(attrs)
      else
        School.create!(attrs)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
  end

private

  def attrs_with_responsible_body_id(school_data)
    rb_id = responsible_body_id(school_data[:responsible_body])
    school_data.merge(responsible_body_id: rb_id).except(:responsible_body)
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
