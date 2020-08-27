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

  def create_school_csv_file(filename, array_of_hashes)
    create_csv_file(filename, SCHOOL_ATTRS.values, array_of_hashes)
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

  def remove_file(filename)
    File.delete(filename) if File.exist?(filename)
  end

  def create_csv_file(filename, headings, array_of_hashes)
    CSV.open(filename, 'w') do |csv|
      csv << headings
      array_of_hashes.each do |row|
        csv << build_row(row)
      end
    end
  end

  def build_row(data)
    SCHOOL_ATTRS.keys.map do |k|
      data.fetch(k, '')
    end
  end
end

RSpec.configure do |c|
  c.include CSVFileHelper
end
