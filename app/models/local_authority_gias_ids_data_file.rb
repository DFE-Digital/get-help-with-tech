class LocalAuthorityGiasIdsDataFile < CsvDataFile
  def extract_record(row)
    {
      eng: row['Local Authority ENG'],
      gias_id: row['Local Authority GIAS ID'],
    }
  end

  def import_record!(record)
    la = LocalAuthority.find_by_local_authority_eng!(record[:eng])
    la.update!(gias_id: record[:gias_id])
  end
end
