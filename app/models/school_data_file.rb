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
      phase: phase(row),
      establishment_type: establishment_type(row),
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

  def phase(row)
    phase_name = row['PhaseOfEducation (name)']
    case phase_name
    when 'Primary', 'Middle deemed primary'
      'primary'
    when 'Secondary', 'Middle deemed secondary'
      'secondary'
    when 'All-through'
      'all_through'
    when '16 plus'
      'sixteen_plus'
    else
      'phase_not_applicable'
    end
  end

  def establishment_type(row)
    est_type = row['EstablishmentTypeGroup (name)']
    case est_type
    when 'Academies'
      'academy'
    when 'Free Schools'
      'free'
    when 'Local authority maintained schools'
      'local_authority'
    when 'Special schools'
      'special'
    else
      Rails.logger.info("Other establishment type? '#{est_type}' (urn: #{row['URN']}")
      'other_type'
    end
  end

  def skip_school?(row)
    school_not_open?(row) ||
      row['LA (name)'] == 'Vale of Glamorgan' ||
      EXCLUDED_TYPES.include?(row['TypeOfEstablishment (name)'])
  end

  def school_not_open?(row)
    !row['EstablishmentStatus (name)'].in? ['Open', 'Open, but proposed to close']
  end
end
