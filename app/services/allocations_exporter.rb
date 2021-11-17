require 'csv'
require 'string_utils'

class AllocationsExporter
  include StringUtils

  attr_reader :filename

  def initialize(filename = nil)
    @filename = filename
  end

  def export(query = schools)
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

  def self.headings
    [
      'School URN',
      'School Name',
      'School Computacenter reference',
      'Responsible body name',
      'Responsible body Computacenter reference',
      'Order state',
      'Who will order devices',
      'Devices allocation',
      'Devices cap',
      'Devices ordered',
      'Pool devices allocation',
      'Pool devices cap',
      'Pool devices ordered',
      'Routers allocation',
      'Routers cap',
      'Routers ordered',
      'Pool routers allocation',
      'Pool routers cap',
      'Pool routers ordered',
    ].freeze
  end

private

  def render(csv, query)
    csv << self.class.headings
    query.find_each do |school|
      csv << [
        school.urn,
        school.name,
        school.computacenter_reference,
        school.responsible_body.name,
        school.responsible_body.computacenter_identifier,
        school.order_state,
        school.who_will_order_devices,
        school.raw_allocation(:laptop),
        school.raw_cap(:laptop),
        school.raw_devices_ordered(:laptop),
        (school.vcap? ? school.allocation(:laptop) : nil),
        (school.vcap? ? school.cap(:laptop) : nil),
        (school.vcap? ? school.devices_ordered(:laptop) : nil),
        school.raw_allocation(:router),
        school.raw_cap(:router),
        school.raw_devices_ordered(:router),
        (school.vcap? ? school.allocation(:router) : nil),
        (school.vcap? ? school.cap(:router) : nil),
        (school.vcap? ? school.devices_ordered(:router) : nil),
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end
  end

  def build_name_fields_for(school)
    split_string("#{school.urn} #{school.name}", limit: 35)
  end

  def schools
    School.all.includes(:responsible_body).order(urn: :asc)
  end
end
