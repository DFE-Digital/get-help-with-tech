class Computacenter::SoldToDataFile < CsvDataFile
  attr_accessor :logger, :failures, :successes

  def extract_record(row)
    {
      urn: row['URN'],
      name: row['Name 1'],
      sold_to: row['Customer'],
    }
  end

  def import_record!(record)
    rb = ResponsibleBody.find_by_computacenter_urn!(record[:urn])
    rb.update!(computacenter_reference: record[:sold_to])
  end
end
