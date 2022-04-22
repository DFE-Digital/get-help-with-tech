class Computacenter::API::APIError < StandardError
  attr_accessor :status, :detail

  def initialize(params = {})
    @status = params[:status]
    @detail = params[:detail]
    super(params[:message])
  end

  def to_h
    {
      status:,
      message:,
      detail:,
    }
  end

  def to_xml(options = {})
    to_h.to_xml({ root: 'error', skip_types: true }.merge!(options))
  end
end
