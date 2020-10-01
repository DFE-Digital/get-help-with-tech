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
    Staging::DataUpdateRecord.staged!(:schools)
  end

  def import_school_links
    datasource.school_links do |link_data|
      school = Staging::School.find_by(urn: link_data[:urn])

      if school
        link = school.school_links.find_by(link_urn: link_data[:link_urn])
        if link
          link.assign_attributes(link_data.except(:urn))
          if link.changed?
            link.save!
            school.touch
          end
        else
          school.school_links.create!(link_data.except(:urn))
          school.touch
        end
      end
    end
    Staging::DataUpdateRecord.staged!(:school_links)
  end
end
