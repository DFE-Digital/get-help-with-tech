class TrustDataFile < CsvDataFile
  def trusts(&block)
    records(&block)
  end

protected

  def extract_record(row)
    record = {}
    DataStage::Trust::ATTR_MAP.each do |k, v|
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
