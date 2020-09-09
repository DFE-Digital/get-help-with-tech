require 'http'

module Gsuite
  class DomainLookupError < StandardError; end

  def self.is_gsuite_domain?(domain)
    response = HTTP.get("https://dns.google.com/resolve?name=#{domain}&type=MX")
    if response.status.success?
      payload = JSON.parse(response.body)
      payload['Answer']&.any? { |h| h['data'] =~ /\.google\.com/i }
    else
      raise Gsuite::DomainLookupError "Domain lookup failed: #{response.status}"
    end
  end
end
