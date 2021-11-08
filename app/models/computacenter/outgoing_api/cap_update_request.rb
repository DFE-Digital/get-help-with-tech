require 'nokogiri'

class Computacenter::OutgoingAPI::CapUpdateRequest
  attr_accessor :endpoint, :username, :password, :cap_data, :timestamp, :body, :payload_id, :response, :logger

  def initialize(args = {})
    @endpoint = args[:endpoint] || setting(:endpoint)
    @username = args[:username] || setting(:username)
    @password = args[:password] || setting(:password)
    @timestamp = args[:timestamp] || Time.zone.now
    @payload_id = args[:payload_id]
    @cap_data = args[:cap_data]
    @logger = args[:logger] || Rails.logger
  end

  def post
    # Need to regenerate this for every request, but still allow for
    # overrides when testing
    @payload_id ||= SecureRandom.uuid
    @body = construct_body
    Rails.logger.info("POSTing to Computacenter, payload_id: #{payload_id}, body: \n#{body}")
    @response = HTTP.basic_auth(user: username, pass: password).post(endpoint, body: body)
    Rails.logger.info("Response from Computacenter: \n#{response.body}")
    self
  end

  def success?
    @success ||= response.status.success? && xml_success?
  end

private

  def construct_body
    renderer.render(:cap_update_request, format: :xml, assigns: { allocations: cap_data,
                                                                  payload_id: payload_id,
                                                                  timestamp: timestamp })
  end

  def renderer
    Computacenter::OutgoingAPI::BaseController
  end

  def setting(name)
    Settings.computacenter.outgoing_api.send(name)
  end

  def xml_response
    @xml_response ||= Nokogiri::XML(response.body)
  end

  def xml_success?
    return true if xml_response.css('HeaderResult').blank?

    xml_response.css('HeaderResult').attr('status').value == 'Success'
  end
end
