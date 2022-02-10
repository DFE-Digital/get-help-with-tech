require 'csv'

module Importers
  class Orders
    attr_reader :path

    # Mapping from CC CSV headers to database columns

    STRINGS_FIELDS = {
      customerordernumber: :raw_customer_order_number,
      manufacturername: :raw_manufacturer_name,
      materialdescription: :raw_material_description,
      materialnumber: :raw_material_number,
      persona: :raw_persona,
      personadescription: :raw_persona_description,
      salesordernumber: :raw_sales_order_number,
      shiptoaccountno: :raw_ship_to_account_no, # school.computacenter_reference
      shiptocustomer: :raw_ship_to_customer,
      soldtoaccountno: :raw_sold_to_account_no, # responsible_body.computacenter_reference
      soldtocustomer: :raw_sold_to_customer,
      urn_cc: :raw_urn_cc,
    }.freeze

    INTEGER_FIELDS = {
      orderdaystodelivery: :raw_order_days_to_delivery,
      orderdaystodespatch: :raw_order_days_to_despatch,
      quantitycompleted: :raw_quantity_completed,
      quantityordered: :raw_quantity_ordered,
      quantityoutstanding: :raw_quantity_outstanding,
    }.freeze

    DATE_FIELDS = {
      deliverydate: :raw_delivery_date,
      despatchdate: :raw_despatch_date,
      orderdate: :raw_order_date,
    }.freeze

    BOOLEAN_FIELDS = {
      isreturn: :raw_is_return,
      ordercompleted: :raw_order_completed,
    }.freeze

    FLAGGED_FIELDS = {
      school_urn: :raw_school_urn, # school.urn
    }.freeze

    MAPPINGS = STRINGS_FIELDS.merge(INTEGER_FIELDS).merge(DATE_FIELDS).merge(BOOLEAN_FIELDS).merge(FLAGGED_FIELDS)

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
        Computacenter::Order.create!(attrs)
        print "#{i} "
      end
      puts 'Ingestion complete'
    end

    # Process each raw column that shouldn't just be a string and copy to a typed column without 'raw_'
    def process
      puts 'Processing raw fields'
      process_date_fields
      process_boolean_fields
      process_integer_fields
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
        Computacenter::Order.update_all("#{unraw(t)} = to_date(#{t}, 'DD/MM/YYYY')")
      end
    end

    def process_boolean_fields
      BOOLEAN_FIELDS.each do |_, t|
        puts "Casting #{t} => #{unraw(t)} as a boolean"
        Computacenter::Order.update_all("#{unraw(t)} = #{t}::boolean")
      end
    end

    def process_integer_fields
      INTEGER_FIELDS.each do |_, t|
        puts "Casting #{t} => #{unraw(t)} as an integer"
        Computacenter::Order.update_all("#{unraw(t)} = #{t}::integer")
      end
    end

    # flagged rows processed in different ways
    def process_flagged_fields
      puts 'Casting raw_school_urn => school_urn as an integer'
      Computacenter::Order.where(raw_school_urn_flag: nil).update_all('school_urn = raw_school_urn::integer')

      puts "Copy raw_school_urn => provision_urn as a string for flagged 'provision_urn'"
      Computacenter::Order.where(raw_school_urn_flag: 'provision_urn').update_all('provision_urn = raw_school_urn')
    end
  end
end
