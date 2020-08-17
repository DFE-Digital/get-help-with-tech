require 'csv'

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
}.freeze

def create_school_csv_file(filename, array_of_hashes)
  create_csv_file(filename, SCHOOL_ATTRS.values, array_of_hashes)
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
