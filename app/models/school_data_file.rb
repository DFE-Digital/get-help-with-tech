require 'csv'

class SchoolDataFile
  def initialize(csv_path)
    @csv_path = csv_path
  end

  def schools(&block)
    all_schools = []
    CSV.foreach(@csv_path, headers: true, encoding: 'ISO8859-1:utf-8') do |row|
      next if skip_school?(row)

      school_data = school_attrs(row)

      if block_given?
        yield school_data
      else
        all_schools << school_data
      end
    end
    all_schools unless block_given?
  end

private

  def school_attrs(row)
    {
      urn: row['URN'],
      name: row['EstablishmentName'],
      responsible_body: row['LA (name)'],
    }
  end

  def skip_school?(row)
    row['EstablishmentStatus (name)'] != 'Open' ||
      row['LA (name)'] == 'Does not apply' ||
      row['LA (name)'] =~ /Overseas Establishments$/ ||
      row['LA (name)'] == 'Vale of Glamorgan' ||
      row['LA (name)'] == 'Isles Of Scilly' ||
      row['TypeOfEstablishment (name)'] == 'Offshore schools' ||
      row['EstablishmentTypeGroup (name)'] == 'Welsh schools'
  end
end
