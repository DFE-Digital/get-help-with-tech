require 'csv'
require 'string_utils'

class SchoolDataExporter
  include StringUtils

  attr_reader :filename

  def initialize(filename = nil)
    @filename = filename
  end

  def export_schools(query = schools)
    if filename
      CSV.open(filename, 'w') do |csv|
        render(csv, query)
      end
      nil
    else
      CSV.generate(headers: true) do |csv|
        render(csv, query)
      end
    end
  end

private

  def render(csv, query)
    csv << headings
    query.find_each do |school|
      csv << [
        school.responsible_body.computacenter_identifier,
        *build_name_fields_for(school),
        school.address_1,
        school.address_2,
        school.address_3,
        school.town,
        school.postcode,
        school.computacenter_change&.capitalize,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
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
      'New/Amended',
    ].freeze
  end

  def build_name_fields_for(school)
    split_string("#{school.urn} #{school.name}", limit: 35)
  end

  def schools
    School.all.includes(:responsible_body).order(urn: :asc, ukprn: :asc, provision_urn: :asc)
  end
end
