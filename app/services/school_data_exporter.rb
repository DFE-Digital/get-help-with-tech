require 'csv'

class SchoolDataExporter
  attr_reader :filename

  EXPORT_ATTRS = %i[
    urn
    name
    address_1
    address_2
    address_3
    town
    county
    postcode
    responsible_body_name
  ].freeze

  def initialize(filename)
    @filename = filename
  end

  def export_schools
    CSV.open(filename, 'w') do |csv|
      csv << headings
      schools.each do |school|
        csv << EXPORT_ATTRS.map do |attr|
          if attr == :responsible_body_name
            if school.responsible_body.type == 'LocalAuthority'
              school.responsible_body.local_authority_official_name
            else
              school.responsible_body.name
            end
          else
            school.send(attr)
          end
        end
      end
    end
    nil
  end

private

  def headings
    EXPORT_ATTRS.map { |s| s.to_s.humanize.titlecase }
  end

  def schools
    School.all.includes(:responsible_body).order(urn: :asc)
  end
end
