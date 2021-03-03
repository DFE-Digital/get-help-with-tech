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
        school.std_device_allocation&.raw_allocation,
        school.std_device_allocation&.raw_cap,
        school.std_device_allocation&.raw_devices_ordered,
        (school.in_virtual_cap_pool? ? school.std_device_allocation&.allocation : nil),
        (school.in_virtual_cap_pool? ? school.std_device_allocation&.cap : nil),
        (school.in_virtual_cap_pool? ? school.std_device_allocation&.devices_ordered : nil),
        school.coms_device_allocation&.raw_allocation,
        school.coms_device_allocation&.raw_cap,
        school.coms_device_allocation&.raw_devices_ordered,
        (school.in_virtual_cap_pool? ? school.coms_device_allocation&.allocation : nil),
        (school.in_virtual_cap_pool? ? school.coms_device_allocation&.cap : nil),
        (school.in_virtual_cap_pool? ? school.coms_device_allocation&.devices_ordered : nil),
      ]
    end
  end

  def build_name_fields_for(school)
    split_string("#{school.urn} #{school.name}", limit: 35)
  end

  def schools
    School.all.includes(:responsible_body, :std_device_allocation, :coms_device_allocation).order(urn: :asc)
  end
end
