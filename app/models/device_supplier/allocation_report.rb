class DeviceSupplier::AllocationReport < TemplateClassCsv
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

private

  def add_headers
    csv << self.class.headers
  end

  def add_report_rows
    School.where(id: scope_ids).includes(:responsible_body).find_each do |school|
      add_school_to_csv(csv, school)
    end
  end

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
end
