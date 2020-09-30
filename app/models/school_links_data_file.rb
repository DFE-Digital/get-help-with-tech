class SchoolLinksDataFile < CsvDataFile
  def school_links(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      urn: row['URN'],
      link_urn: row['LinkURN'],
      link_type: row['LinkType'],
    }
  end
end
