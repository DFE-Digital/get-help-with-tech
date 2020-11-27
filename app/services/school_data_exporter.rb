require 'csv'
require 'string_utils'

class SchoolDataExporter
  include StringUtils

  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def export_schools(query = schools)
    CSV.open(filename, 'w') do |csv|
      csv << headings
      query.find_each do |school|
        csv << [
          school.responsible_body.computacenter_identifier,
          *build_name_fields_for(school),
          school.delivery_address.address_1,
          school.delivery_address.address_2,
          school.delivery_address.address_3,
          school.delivery_address.town,
          school.delivery_address.postcode,
        ]
      end
    end
    nil
  end

private

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
    ].freeze
  end

  def build_name_fields_for(school)
    split_string("#{school.urn} #{school.name}", limit: 35)
  end

  def schools
    School.all.includes(:responsible_body).order(urn: :asc)
  end
end
