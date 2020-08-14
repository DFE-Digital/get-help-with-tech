# We're designing our API endpoint to fit the client's specification.
# We'd normally do it the other way round, but due to the urgency of the
# need and the fact that it's probably faster for to iterate our system
# than theirs, this is the most pragmatic solution.
# The client's specification here is XML-based, and not strictly RESTful -
# all XML packets will be sent as a POST, regardless of the action.
# So we're pulling this out to a dedicated controller in order to keep the
# rest of the application 'clean' and RESTful.
class Computacenter::API::BaseController < ApplicationController
  before_action :require_cc_user!
  rescue_from APIError, with: :api_error!

private

  def identify_user!
    @user = APIToken.active.find_by(token: bearer_token)&.user
  end

  def bearer_token
    request.headers['Authorization']&.gsub(/Bearer\s+([^\s]*)$/, '\1')
  end

  # overriden method tailored for XML responses
  def require_cc_user!
    if bearer_token.present?
      raise APIError.new(status: :forbidden, message: 'You are not authorized to perform this action') unless @user&.is_computacenter?
    else
      raise APIError.new(status: :unauthorized, message: 'You must provide an Authorization header with a valid Bearer token')
    end
  end

  def api_error!(error)
    render xml: error, status: error.status and return
  end

  def validate_xml!(xml, schema_name)
    errors = ComputacenterAPISchema.new(schema_name).validate(xml)
    unless errors.empty?
      raise APIError.new(
        status: :bad_request,
        message: "The XML you provided was not valid according to the schema #{schema_name}",
        detail: errors
      )
    end
  end
end
