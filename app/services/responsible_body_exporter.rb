require 'csv'
require 'string_utils'

class ResponsibleBodyExporter
  include StringUtils

  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def export_responsible_bodies(query = responsible_bodies)
    CSV.open(filename, 'w') do |csv|
      csv << headings
      query.find_each do |rb|
        csv << [
          rb.computacenter_identifier,
          *build_name_fields_for(rb),
          rb.address_1,
          rb.address_2,
          rb.address_3,
          rb.town,
          rb.postcode,
        ]
      end
    end
    nil
  end

private

  def headings
    [
      'Responsible body URN',
      'Responsible Body Name',
      'Responsible Body Name (overflow)',
      'Address line 1',
      'Address line 2',
      'Address line 3',
      'Town/City',
      'Postcode',
    ].freeze
  end

  def build_name_fields_for(responsible_body)
    split_string(responsible_body.computacenter_name, limit: 35)
  end

  def responsible_bodies
    ResponsibleBody.where.not(name: 'Department for Education').order(type: :asc, name: :asc)
  end
end
