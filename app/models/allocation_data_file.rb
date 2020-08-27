class AllocationDataFile < CsvDataFile
  def allocations(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      urn: row['URN'],
      name: row['Name'],
      y3_10: row['Y3-Y10'].to_i,
      y10: row['Y10 Allocation'].to_i,
    }
  end
end
