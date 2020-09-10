require 'http'

module Gsuite
  class DomainLookupError < StandardError; end

  def self.is_gsuite_domain?(domain, logger = nil)
    has_service_login?(domain, logger)
  end

  def self.has_google_mx_record?(domain, logger = nil)
    response = HTTP.get("https://dns.google.com/resolve?name=#{domain}&type=MX")
    if response.status.success?
      payload = JSON.parse(response.body)
      logger.debug(payload) if logger

      payload['Answer']&.any? { |h| h['data'] =~ /\.google(mail)?\.com/i }
    else
      raise DomainLookupError, "Domain lookup failed: #{response.status}"
    end
  end

  def self.has_service_login?(domain, logger = nil)
    response = HTTP.get("https://www.google.com/a/#{domain}/ServiceLogin")
    if response.status.success?
      body = response.body.to_s
      logger.debug body if logger
      body =~ /Sign in - Google Accounts/
    elsif response.status.redirect?
      # the redirects all seem to be to SAML providers for logins
      logger.debug response.body.to_s if logger
      true
    else
      raise DomainLookupError, "Service lookup failed: #{response.status}"
    end
  end
end
