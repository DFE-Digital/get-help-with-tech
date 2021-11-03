# Service to export allocations data for the device supplier
class DeviceSupplierExportAllocationsService
  attr_reader :path
  attr_accessor :progress_percentage, :count, :per_school_percentage

  UPDATE_PROGRESS_DELAY = 200

  def initialize(path = nil)
    @path = path
    @progress_percentage = 0
    @count = 0
    @per_school_percentage = 100.0 / School.count
  end

  def call(target_path = path)
    raise 'No path specified' if target_path.nil?

    CSV.open(target_path, 'wb') do |csv|
      csv << csv_headers
      School.includes(:responsible_body).find_each do |school|
        update_progress
        add_school_to_csv(csv, school)
      end
    end
    Rails.logger.info "DeviceSupplierExportAllocationsService: Exported #{count} schools to #{path}"
  end

private

  def add_school_to_csv(csv, school)
    csv << school_allocation_and_rb_details(school)
  end

  def csv_headers
    %w[urn
       order_state
       who_orders
       ship_to
       sold_to
       school_name
       school_address_1
       school_address_2
       school_address_3
       school_town
       school_county
       school_postcode
       responsible_body_id
       responsible_body_name
       rb_address_1
       rb_address_2
       rb_address_3
       rb_town
       rb_county
       rb_postcode
       allocation
       cap
       adjusted_cap_if_vcap_enabled
       devices_ordered
       virtual_cap_enabled?
       school_in_virtual_cap?]
  end

  def csv_row(school, responsible_body, ship_to, sold_to)
    [school.urn,
     school.order_state,
     school.who_will_order_devices,
     ship_to,
     sold_to,
     school.name,
     school.address_1,
     school.address_2,
     school.address_3,
     school.town,
     school.county,
     school.postcode,
     responsible_body.computacenter_identifier,
     responsible_body.name,
     responsible_body.address_1,
     responsible_body.address_2,
     responsible_body.address_3,
     responsible_body.town,
     responsible_body.county,
     responsible_body.postcode,
     school.raw_allocation(:laptop),
     school.cannot_order? ? school.raw_devices_ordered(:laptop) : school.raw_cap(:laptop),
     school.computacenter_cap(:laptop),
     school.raw_devices_ordered(:laptop),
     rb_vcap_feature_flag_text(school),
     schools_vcap_enabled_text(school)]
  end

  def rb_vcap_feature_flag_text(school)
    school.responsible_body.vcap_active? ? 'Yes' : 'No'
  end

  def school_allocation_and_rb_details(school)
    responsible_body = school.responsible_body
    ship_to = school.computacenter_reference
    sold_to = responsible_body.computacenter_reference

    csv_row(school, responsible_body, ship_to, sold_to)
  end

  def schools_vcap_enabled_text(school)
    school.in_virtual_cap_pool? ? 'Yes' : 'No'
  end

  def update_progress
    @progress_percentage += @per_school_percentage
    @count += 1
    Rails.logger.info "\nDeviceSupplierExportAllocationsService percentage: #{@progress_percentage.to_i}%\n" if (@count % UPDATE_PROGRESS_DELAY).zero?
  end
end
