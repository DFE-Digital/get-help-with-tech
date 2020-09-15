class Computacenter::OutgoingAPI::Error < StandardError
  attr_accessor :cap_update_request

  def initialize(params = {})
    @cap_update_request = params[:cap_update_request]
    super
  end
end
