require 'open-uri'
require 'csv'
require 'net/http'

class GetInformationAboutSchools
  EDUBASE_URL = 'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/'.freeze

  def self.trusts_entries
    gias_csv = URI.parse(groups_url).read.force_encoding(Encoding::ISO8859_1)
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
    url = URI.parse(schools_url)
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

  def self.groups_url
    "#{EDUBASE_URL}allgroupsdata.csv"
  end

  def self.schools_url(date: Time.zone.now)
    "#{EDUBASE_URL}edubasealldata#{date.strftime('%Y%m%d')}.csv"
  end
end
