require 'open-uri'
require 'csv'
require 'net/http'

class GetInformationAboutSchools
  URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata.csv'.freeze

  SCHOOLS_URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata%{date}.csv'.freeze

  def self.trusts_entries
    gias_csv = URI.parse(URL).read.force_encoding(Encoding::ISO8859_1)
    CSV.parse(gias_csv, headers: true).select { |row|
      row['Group Type'].in?(['Single-academy trust', 'Multi-academy trust']) && row['Group Status'] == 'Open'
    }.map(&:to_h)
  end

  def self.schools(&block)
    file = Tempfile.new
    fetch_latest_edubase_file(file)
    SchoolDataFile.new(file.path).schools(&block)
  ensure
    file.close
    file.unlink
  end

  def self.fetch_latest_edubase_file(file)
    url = gias_url
    Net::HTTP.start(url.host, url.port,
                    use_ssl: url.scheme == 'https') do |http|
      http.request_get(url.path) do |resp|
        resp.read_body do |chunk|
          file.write(chunk.force_encoding(Encoding::ISO8859_1))
        end
      end
    end
    file.rewind
  end

  def self.gias_url(date: Time.zone.now)
    URI.parse(sprintf(SCHOOLS_URL, date: date.strftime('%Y%m%d')))
  end
end
