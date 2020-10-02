class TrustDataFile < CsvDataFile
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
      status: row['Group Status']&.downcase,
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
end
