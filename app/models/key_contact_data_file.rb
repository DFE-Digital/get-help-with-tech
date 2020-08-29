class KeyContactDataFile < CsvDataFile
  def contacts(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      id: row['ID'],
      email_address: row['Email']&.downcase,
      full_name: name_or_email(row),
      telephone: row['Telephone'],
    }
  end

private

  def name_or_email(row)
    row['Name'] || row['Email']&.downcase
  end
end
