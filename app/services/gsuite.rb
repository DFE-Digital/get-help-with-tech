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
      raise Gsuite::DomainLookupError.new("Domain lookup failed: #{response.status}")
    end
  end

  def self.has_service_login?(domain, logger = nil)
    response = HTTP.get("https://www.google.com/a/#{domain}/ServiceLogin")
    if response.status.success?
      if response.body.to_s =~ /Sign in - Google Accounts/
        true
      elsif response.body.to_s =~ /Sorry, you've reached a login page for a domain that isn't using G Suite/
        false
      else
        logger.debug response.body.to_s if logger
        false
      end
    elsif response.status.redirect?
      # the redirects all seem to be to SAML providers for logins
      logger.debug response.body.to_s if logger
      true
    else
      raise Gsuite::DomainLookupError.new("Service lookup failed: #{response.status}")
    end
  end
end
