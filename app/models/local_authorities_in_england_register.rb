require 'open-uri'

class LocalAuthoritiesInEnglandRegister
  URL = 'https://local-authority-eng.register.gov.uk/records.json?page-size=5000'.freeze

  def self.entries
    local_authorities_register_results = JSON.parse(URI.open(URL).read)

    local_authorities_register_results
      .values
      .map { |result| result['item'].first }
      .reject { |result| result['end-date'].present? }
  end
end
