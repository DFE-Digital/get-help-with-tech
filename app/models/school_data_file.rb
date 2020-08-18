require 'csv'

class SchoolDataFile
  EXCLUDED_TYPES = [
    'British schools overseas',
    'Further education',
    'Higher education institutions',
    'Institution funded by other government department',
    'Miscellaneous',
    'Offshore schools',
    'Other independent school',
    'Other independent special school',
    'Secure units',
    'Sixth form centres',
    'Special post 16 institution',
    'Welsh establishment',
  ].freeze

  def initialize(csv_path)
    @csv_path = csv_path
  end

  def schools
    all_schools = []
    CSV.foreach(@csv_path, headers: true, encoding: 'ISO8859-1:utf-8') do |row|
      next if skip_school?(row)

      school_data = school_attrs(row)

      if block_given?
        yield school_data
      else
        all_schools << school_data
      end
    end
    all_schools unless block_given?
  end

private

  def school_attrs(row)
    {
      urn: row['URN'],
      name: row['EstablishmentName'],
      responsible_body: find_responsible_body(row),
      address_1: row['Street'],
      address_2: row['Locality'],
      address_3: row['Address3'],
      town: row['Town'],
      county: row['County (name)'],
      postcode: row['Postcode'],
    }
  end

  def find_responsible_body(row)
    # 3 - Multi-academy trust
    # 5 - Single-academy trust
    if row['TrustSchoolFlag (code)'].in? %w[3 5]
      row['Trusts (name)']
    else
      row['LA (name)']
    end
  end

  def skip_school?(row)
    row['EstablishmentStatus (name)'] != 'Open' ||
      row['LA (name)'] == 'Does not apply' ||
      row['LA (name)'] == 'Vale of Glamorgan' ||
      row['LA (name)'] == 'Isles Of Scilly' ||
      EXCLUDED_TYPES.include?(row['TypeOfEstablishment (name)'])
  end
end
