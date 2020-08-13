class ImportSchoolsService
  attr_reader :datasource

  RB_NAME_MAP = {
    'Bristol, City of' => 'City of Bristol',
    'Kingston upon Hull, City of' => 'Kingston upon Hull',
    'Herefordshire, County of' => 'Herefordshire',
  }.freeze

  def initialize(school_datasource = GetInformationAboutSchools)
    @datasource = school_datasource
  end

  def import_schools
    datasource.schools do |school_data|
      School.find_or_create_by!(urn: school_data[:urn]) do |school|
        school.name = school_data[:name]
        school.responsible_body_id = responsible_body_id(school_data[:responsible_body])
      end
    end
  end

private

  def responsible_body_id(name)
    rb_id = ResponsibleBody.find_by(name: rb_name(name))&.id

    Rails.logger.info "Did not find responsible body: #{name}" unless rb_id

    rb_id
    end
  end

  def rb_name(name)
    RB_NAME_MAP.fetch(name, name)
  end
end
