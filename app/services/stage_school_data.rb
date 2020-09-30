class StageSchoolData
  attr_reader :datasource

  def initialize(school_datasource = GetInformationAboutSchools)
    @datasource = school_datasource
  end

  def import_schools
    datasource.schools do |school_data|
      school = Staging::School.find_by(urn: school_data[:urn])

      if school
        school.update!(school_data)
      else
        Staging::School.create!(school_data)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
    end
  end

  def import_school_links
    datasource.school_links do |link_data|
      school = Staging::School.find_by(urn: link_data[:urn])

      if school
        school.update!(link_data)
      else
        Rails.logger.info("URN (#{link_data[:urn]}) not found, could not add link data")
      end
    end
  end
end
