require 'csv'

module CSVFileHelper
  SCHOOL_ATTRS = {
    urn: 'URN',
    name: 'EstablishmentName',
    responsible_body: 'LA (name)',
    address_1: 'Street',
    address_2: 'Locality',
    address_3: 'Address3',
    town: 'Town',
    county: 'County (name)',
    postcode: 'Postcode',
    status: 'EstablishmentStatus (name)',
    type: 'TypeOfEstablishment (name)',
    trusts_flag: 'TrustSchoolFlag (code)',
    trusts_name: 'Trusts (name)',
    phase: 'PhaseOfEducation (name)',
    group_type: 'EstablishmentTypeGroup (name)',
    head_first_name: 'HeadFirstName',
    head_last_name: 'HeadLastName',
    head_title: 'HeadTitle (name)',
    head_preferred_title: 'HeadPreferredJobTitle',
    telephone: 'TelephoneNum',
    head_email: 'HeadEmail',
    main_email: 'MainEmail',
    alt_email: 'AlternativeEmail',
    school_name: 'Name',
    y3_10: 'Y3-Y10',
    y10: 'Y10 Allocation',
  }.freeze

  KEY_CONTACT_ATTRS = {
    id: 'ID',
    email_address: 'Email',
    full_name: 'Name',
    telephone: 'Telephone',
  }.freeze

  SCHOOL_LINKS_ATTRS = {
    urn: 'URN',
    link_urn: 'LinkURN',
    link_type: 'LinkType',
  }.freeze

  EXTRA_MOBILE_DATA_REQUEST_STATUS_UPDATE_ATTRS = {
    id: 'ID',
    account_holder_name: 'Account holder name',
    device_phone_number: 'Device phone number',
    created_at: 'Requested',
    updated_at: 'Last updated',
    mobile_network_id: 'Mobile network ID',
    status: 'Status',
    contract_type: 'Contract type',
  }.freeze

  def create_school_csv_file(filename, array_of_hashes)
    create_csv_file(filename, SCHOOL_ATTRS.values, array_of_hashes)
  end

  def create_school_links_csv_file(filename, array_of_hashes)
    create_csv_file(filename, SCHOOL_LINKS_ATTRS.values, array_of_hashes, SCHOOL_LINKS_ATTRS)
  end

  def create_trust_csv_file(filename, array_of_hashes)
    attrs = TrustDataFile::ATTR_MAP
    create_csv_file(filename, attrs.values, array_of_hashes, attrs)
  end

  def create_extra_mobile_data_request_update_csv_file(filename, array_of_hashes)
    attrs = EXTRA_MOBILE_DATA_REQUEST_STATUS_UPDATE_ATTRS
    create_csv_file(filename, attrs.values, array_of_hashes, attrs)
  end

  def create_allocations_csv_file(filename, array_of_hashes)
    head_keys = array_of_hashes.first.keys
    headings = head_keys.map { |k| SCHOOL_ATTRS[k] }

    CSV.open(filename, 'w') do |csv|
      csv << headings
      array_of_hashes.each do |row|
        csv << head_keys.map { |k| row.fetch(k) }
      end
    end
  end

  def create_key_contacts_csv_file(filename, array_of_hashes)
    create_csv_file(filename, KEY_CONTACT_ATTRS.values, array_of_hashes, KEY_CONTACT_ATTRS)
  end

  def remove_file(filename)
    File.delete(filename) if File.exist?(filename)
  end

  def create_csv_file(filename, headings, array_of_hashes, data_map = SCHOOL_ATTRS)
    CSV.open(filename, 'w') do |csv|
      csv << headings
      array_of_hashes.each do |row|
        csv << build_row(row, data_map)
      end
    end
  end

  def build_row(data, data_map)
    data_map.keys.map do |k|
      data.fetch(k, nil)
    end
  end
end

RSpec.configure do |c|
  c.include CSVFileHelper
end
