class TrustDataFile < CsvDataFile
  EXCLUDED_TYPES = [
    'British schools overseas',
    "Children's centre",
    "Children's centre linked site",
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

  def trusts(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      name: row['Group Name'],
      organisation_type: row['Group Type'],
      companies_house_number: row['Companies House Number'],
      gias_group_uid: row['Group UID'],
      status: row['Group Status'].downcase,
      address_1: row['Group Street'],
      address_2: row['Group Locality'],
      address_3: row['Group Address 3'],
      town: row['Group Town'],
      county: sanitize_county(row['Group County']),
      postcode: row['Group Postcode'],
    }
  end

  def skip?(row)
    !row['Group Type'].in?(['Single-academy trust', 'Multi-academy trust']) ||
      row['Companies House Number'].blank?
  end

private

  def sanitize_county(value)
    return nil if value == 'Not recorded' || value.blank?

    value
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
    when 'Nursery'
      'nursery'
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

  def status(row)
    case row['EstablishmentStatus (name)']
    when 'Open', 'Open, but proposed to close'
      'open'
    when 'Closed', 'Proposed to open'
      'closed'
    else
      Rails.logger.info("Unknown status type: '#{row['EstablishmentStatus (name)']}'")
    end
  end
end
