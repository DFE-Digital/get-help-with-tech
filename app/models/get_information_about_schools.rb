require 'open-uri'
require 'csv'

class GetInformationAboutSchools
  URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata.csv'.freeze

  def self.trusts_entries
    gias_csv = URI.parse(URL).read.force_encoding(Encoding::ISO8859_1)
    CSV.parse(gias_csv, headers: true).select { |row|
      row['Group Type'].in?(['Single-academy trust', 'Multi-academy trust']) && row['Group Status'] == 'Open'
    }.map(&:to_h)
  end
end
