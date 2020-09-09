require 'http'

module Gsuite
  class DomainLookupError < StandardError; end

  def self.is_gsuite_domain?(domain, logger = nil)
    response = HTTP.get("https://dns.google.com/resolve?name=#{domain}&type=MX")
    if response.status.success?
      payload = JSON.parse(response.body)
      logger.debug(payload) if logger

      payload['Answer']&.any? { |h| h['data'] =~ /\.google(mail)?\.com/i }
    else
      raise Gsuite::DomainLookupError "Domain lookup failed: #{response.status}"
    end
  end
end
