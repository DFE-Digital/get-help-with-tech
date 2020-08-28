class KeyContactDataFile < CsvDataFile
  def contacts(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      id: row['ID'],
      email_address: row['Email']&.downcase,
      full_name: row['Name'],
      telephone: row['Telephone'],
    }
  end
end
