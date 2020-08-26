require 'open-uri'
require 'csv'

class ImportLocalAuthorityGiasIdsService
  attr_accessor :csv_uri

  def initialize(csv_uri)
    @csv_uri = csv_uri
  end

  def import
    csv = open(@csv_uri).read
    index = 0
    CSV.parse(csv, headers: true).select do |row|
      la = LocalAuthority.find_by_local_authority_eng!(row['Local Authority ENG'])
      puts "updating #{la.name} with GIAS ID #{row['Local Authority GIAS ID']}"
      la.update!(gias_id: row['Local Authority GIAS ID'])
    end
  end
end
