require 'open-uri'

class LocalAuthoritiesInEnglandRegister
  URL = 'https://webarchive.nationalarchives.gov.uk/20210122124652/https://local-authority-eng.register.gov.uk/records.json?page-size=5000'.freeze

  # we believe that
  # - combined authorities
  # - strategic regional authorities and
  # - non-metropolitan districts
  # don't maintain schools
  def self.local_authorities_that_maintain_schools
    local_authorities_register_results = JSON.parse(URI.open(URL).read)

    local_authorities_register_results
      .values
      .map { |result| result['item'].first }
      .reject { |result| result['end-date'].present? }
      .reject { |result| result['local-authority-type'].in?(%w[COMB SRA NMD]) }
  end
end
