require 'csv'

# Service to export allocations data for the device supplier
module DeviceSupplier
  class ExportAllocationsService
    attr_reader :path
    attr_accessor :progress_percentage, :count, :per_school_percentage

    UPDATE_PROGRESS_DELAY = 200

    def self.headers
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

    def initialize(path = nil)
      @path = path
      @progress_percentage = 0
      @count = 0
      @per_school_percentage = 100.0 / School.count
    end

    def call(target_path = path)
      raise 'No path specified' if target_path.nil?

      to_csv(target_path)
      Rails.logger.info "DeviceSupplierExportAllocationsService: Exported #{count} schools to #{target_path}"
    end

    def to_csv(path = nil)
      open_or_generate = path.nil? ? [:generate] : [:open, path, 'wb']
      CSV.send(*open_or_generate) do |csv|
        csv << self.class.headers
        School.includes(:responsible_body).find_each do |school|
          update_progress
          add_school_to_csv(csv, school)
        end
      end
    end

  private

    def add_school_to_csv(csv, school)
      csv << csv_row(school)
    end

    def csv_row(school)
      [school.urn,
       school.order_state,
       school.who_will_order_devices,
       school.ship_to,
       school.sold_to,
       school.name,
       school.address_1,
       school.address_2,
       school.address_3,
       school.town,
       school.county,
       school.postcode,
       school.rb.computacenter_identifier,
       school.rb.name,
       school.rb.address_1,
       school.rb.address_2,
       school.rb.address_3,
       school.rb.town,
       school.rb.county,
       school.rb.postcode,
       school.raw_allocation(:laptop),
       school.raw_cap(:laptop),
       school.computacenter_cap(:laptop),
       school.raw_devices_ordered(:laptop),
       rb_vcap_text(school),
       schools_vcap_enabled_text(school)].map { |value| CsvValueSanitiser.new(value).sanitise }
    end

    def rb_vcap_text(school)
      school.responsible_body.vcap? ? 'Yes' : 'No'
    end

    def schools_vcap_enabled_text(school)
      school.vcap? ? 'Yes' : 'No'
    end

    def update_progress
      @progress_percentage += @per_school_percentage
      @count += 1
      Rails.logger.info "\nDeviceSupplierExportAllocationsService percentage: #{@progress_percentage.to_i}%\n" if (@count % UPDATE_PROGRESS_DELAY).zero?
    end
  end
end
