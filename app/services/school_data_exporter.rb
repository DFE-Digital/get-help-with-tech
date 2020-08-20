require 'csv'
require 'string_utils'

class SchoolDataExporter
  include StringUtils
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def export_schools
    CSV.open(filename, 'w') do |csv|
      csv << headings
      schools.each do |school|
        csv <<
          [ computacenter_identifier_for(school.responsible_body) ] +
          split_string("#{school.urn} #{school.name}", limit: 35) +
          [
            school.address_1,
            school.address_2,
            school.address_3,
            school.town,
            school.postcode,
          ]
      end
    end
    nil
  end

private

  def computacenter_identifier_for(responsible_body)
    case responsible_body.type
    when "LocalAuthority"
      "LEA#{responsible_body.gias_id}"
    when "Trust"
      "t#{responsible_body.companies_house_number.to_i}"
    end
  end

  def headings
    [
      'Responsible body URN',
      'School URN + School Name',
      'School Name (overflow)',
      'Address line 1',
      'Address line 2',
      'Address line 3',
      'Town/City',
      'Postcode',
    ]
  end

  def schools
    School.all.includes(:responsible_body).order(urn: :asc)
  end
end
