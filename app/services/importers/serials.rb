require 'csv'

module Importers
  class Serials
    attr_reader :path

    STRINGS_FIELDS = {
      customerordernumber: :raw_customer_order_number, # => computacenter_orders.raw_customer_order_number
      deliverynumber: :raw_delivery_number,
      manufacturername: :raw_manufacturer_name,
      manufacturerpartnumber: :raw_manufacturer_part_number,
      materialdescription: :raw_material_description,
      materialnumber: :raw_material_number,
      ordernumber: :raw_order_number,
      orderposition: :raw_order_position,
      partclassificationdesc: :raw_part_classification_desc,
      persona: :raw_persona,
      personadescription: :raw_persona_description,
      reportquantity: :raw_report_quantity,
      serialnumber: :raw_serial_number,
      shiptoaccountno: :raw_ship_to_account_no,
      shiptoaddress: :raw_ship_to_address,
      shiptocustomer: :raw_ship_to_customer,
      shiptopostcode: :raw_ship_to_post_code,
      shiptotown: :raw_ship_to_town,
      soldtoaccountno: :raw_sold_to_account_no,
      soldtocustomer: :raw_sold_to_customer,
      urn: :raw_urn,
    }.freeze

    DATE_FIELDS = {
      customerorderdate: :raw_customer_order_date,
      despatchdate: :raw_despatch_date,
      orderdate: :raw_order_date,
    }.freeze

    FLAGGED_FIELDS = {
      schoolurn: :raw_school_urn, # school.urn
    }.freeze

    MAPPINGS = STRINGS_FIELDS.merge(DATE_FIELDS).merge(FLAGGED_FIELDS)

    def initialize(path_to_csv)
      @path = path_to_csv
    end

    # Ingest the CSV with as little processing as possible
    def ingest
      puts 'Ingesting CSV to database'
      rows.each_with_index do |r, i|
        attrs = {}
        MAPPINGS.each { |s, t| attrs[t] = r[s]&.strip.presence }
        attrs = flag(attrs)
        Computacenter::Serial.create!(attrs)
        print "#{i} "
      end
      puts 'Ingestion complete'
    end

    # Process each raw column that shouldn't just be a string and copy to a typed column without 'raw_'
    def process
      puts 'Processing raw fields'
      process_date_fields
      process_flagged_fields
    end

  private

    def rows
      @rows ||= CSV.read(path, headers: true, header_converters: :symbol)
    end

    def unraw(raw_field)
      raw_field.to_s.gsub('raw_', '')
    end

    # flag silly/fiddly exceptions row-by-row that are difficult to help scope update_alls
    def flag(attrs)
      flagged_attrs = {}

      # school_urn should contain e.g. '123456' and can be integers
      # but 'SCL123', 'x123456' and 'Something' also exist, flag these here
      raw_school_urn = attrs[:raw_school_urn]
      unless raw_school_urn =~ /^\d+$/
        flagged_attrs[:raw_school_urn_flag] = if raw_school_urn =~ /^SCL\d+$/
                                                'provision_urn'
                                              elsif raw_school_urn =~ /^x\d+$/
                                                'old_urn'
                                              else
                                                'bad_urn'
                                              end
      end

      attrs.merge(flagged_attrs)
    end

    def process_date_fields
      DATE_FIELDS.each do |_, t|
        puts "Casting #{t} => #{unraw(t)} as a date"
        Computacenter::Serial.update_all("#{unraw(t)} = to_date(#{t}, 'DD/MM/YYYY')")
      end
    end

    # flagged rows processed in different ways
    def process_flagged_fields
      puts 'Casting raw_school_urn => school_urn as an integer'
      Computacenter::Serial.where(raw_school_urn_flag: nil).update_all('school_urn = raw_school_urn::integer')

      puts "Copy raw_school_urn => provision_urn as a string for flagged 'provision_urn'"
      Computacenter::Serial.where(raw_school_urn_flag: 'provision_urn').update_all('provision_urn = raw_school_urn')
    end
  end
end
