class Computacenter::ResponsibleBodyUsersDataFile < CsvDataFile
  def extract_record(row)
    {
      full_name: [row['Title'], row['First Name'], row['Last Name']].compact.map(&:strip).join(' ').strip,
      telephone: row['Telephone'].to_s.strip,
      email_address: row['Email'].to_s.strip,
      default_sold_to: row['DefaultSoldto'].to_s.strip,
      sold_tos: row['SoldTos'].to_s.split(',').map(&:strip),
    }
  end

  def import_record!(record)
    rb = find_responsible_body!(record)
    raise(ActiveRecord::RecordNotFound, "Couldn't find a ResponsibleBody with any of these computacenter references: #{record['DefaultSoldto']}, #{record['SoldTos']}") if rb.nil?

    create_user!(record, rb)
  end

  def find_responsible_body!(record)
    # some people in the spreadsheet have multiple 'SoldTos'
    # so let's look for the default one first
    ResponsibleBody.find_by_computacenter_reference(record[:default_sold_to]) || \
      ResponsibleBody.find_by(computacenter_reference: record[:sold_tos])
  end

  def create_user!(record, responsible_body)
    User.create!(
      full_name: record[:full_name],
      telephone: record[:telephone],
      email_address: record[:email_address],
      responsible_body:,
    )
  end
end
