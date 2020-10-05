class TrustDataFile < CsvDataFile

  ATTR_MAP = {
    name: 'Group Name',
    organisation_type: 'Group Type',
    companies_house_number: 'Companies House Number',
    gias_group_uid: 'Group UID',
    status: 'Group Status',
    address_1: 'Group Street',
    address_2: 'Group Locality',
    address_3: 'Group Address 3',
    town: 'Group Town',
    county: 'Group County',
    postcode: 'Group Postcode',
  }.freeze

  def trusts(&block)
    records(&block)
  end

protected

  def extract_record(row)
    record = {}
    ATTR_MAP.each do |k, v|
      record[k] = row[v]
    end
    record
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
end
