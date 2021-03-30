# We're designing our API endpoint to fit the client's specification.
# We'd normally do it the other way round, but due to the urgency of the
# need and the fact that it's probably faster for to iterate our system
# than theirs, this is the most pragmatic solution.
# The client's specification here is XML-based, and not strictly RESTful -
# all XML packets will be sent as a POST, regardless of the action.
# So we're pulling this out to a dedicated controller in order to keep the
# rest of the application 'clean' and RESTful.
class Computacenter::API::BaseController < ApplicationController
  before_action :require_cc_user!, :read_xml_from_body!, :log_request_verbosely
  rescue_from Computacenter::API::APIError, with: :api_error!

private

  def identify_user!
    @current_user = (APIToken.active.find_by(token: bearer_token)&.user || User.new)
  end

  def bearer_token
    request.headers['Authorization']&.gsub(/Bearer\s+([^\s]*)$/, '\1')
  end

  # overriden method tailored for XML responses
  def require_cc_user!
    if bearer_token.present?
      raise Computacenter::API::APIError.new(status: :forbidden, message: 'You are not authorized to perform this action') unless @current_user&.is_computacenter?
    else
      raise Computacenter::API::APIError.new(status: :unauthorized, message: 'You must provide an Authorization header with a valid Bearer token')
    end
  end

  def api_error!(error)
    render xml: error, status: error.status and return
  end

  def read_xml_from_body!
    @xml = request.body.read
    @xml_doc = Nokogiri::XML(@xml)
    @parsed_xml = Hash.from_xml(@xml)
  rescue Nokogiri::XML::SyntaxError, RuntimeError
    raise Computacenter::API::APIError.new(
      status: :bad_request,
      message: 'The request body you provided was not valid XML',
    )
  end

  def log_request_verbosely
    logger.info "request.headers = #{request.headers.to_h.reject { |k, _| k.starts_with?('puma.', 'rack.', 'action_') }.inspect}"
    logger.info "request.format = #{request.format}"
    logger.info "request.accept = #{request.accept}"
    logger.info "request.body: \n#{@xml}"
  end

  def validate_xml!(schema_name, xml_doc = @xml_doc)
    errors = Computacenter::API::Schema.new(schema_name).validate(xml_doc)
    unless errors.empty?
      raise Computacenter::API::APIError.new(
        status: :bad_request,
        message: "The XML you provided was not valid according to the schema #{schema_name}",
        detail: errors,
      )
    end
  end
end
