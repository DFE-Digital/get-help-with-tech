class Computacenter::ShipToAndSoldToDataFile < CsvDataFile
  def extract_record(row)
    {
      rb_urn: row['Responsible Body URN'],
      rb_sold_to: row['Sold To Number'],
      school_urn: row['School URN + School Name'].split(' ').first,
      school_ship_to: row['Ship To Number'],
    }
  end

  def import_record!(record)
    rb = ResponsibleBody.find_by_computacenter_urn!(record[:rb_urn])
    rb.update!(computacenter_reference: record[:rb_sold_to])
    school = School.find_by_urn!(record[:school_urn])
    school.update!(computacenter_reference: record[:school_ship_to])
  end
end
