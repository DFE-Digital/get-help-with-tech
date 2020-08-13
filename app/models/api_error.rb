class APIError < StandardError
  attr_accessor :status

  def initialize(params = {})
    @status = params[:status]
    super(params[:message])
  end

  def to_h
    {
      status: status,
      message: message,
    }
  end

  def to_xml(options = {})
    to_h.to_xml({ root: 'error', skip_types: true }.merge!(options))
  end
end
