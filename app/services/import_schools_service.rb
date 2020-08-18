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
      School.find_or_create_by!(urn: school_data[:urn]) do |school|
        school.name = school_data[:name]
        school.responsible_body_id = responsible_body_id(school_data[:responsible_body])
        school.address_1 = school_data[:address_1]
        school.address_2 = school_data[:address_2]
        school.address_3 = school_data[:address_3]
        school.town = school_data[:town]
        school.county = school_data[:county]
        school.postcode = school_data[:postcode]
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
  end

private

  def responsible_body_id(name)
    rb_id = ResponsibleBody.find_by(name: rb_name(name))&.id

    Rails.logger.error("Did not find responsible body: #{name}") unless rb_id

    rb_id
  end

  def rb_name(name)
    RB_NAME_MAP.fetch(name, name)
  end
end
