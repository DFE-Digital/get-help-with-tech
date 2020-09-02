class Computacenter::ShipToDataFile < CsvDataFile
  def extract_record(row)
    {
      urn: row['URN'],
      name: row['Name 1'],
      ship_to: row['Ship to acct'],
    }
  end

  def import_record!(record)
    school = School.find_by_urn!(record[:urn])
    school.update!(computacenter_reference: record[:ship_to])
  end
end
