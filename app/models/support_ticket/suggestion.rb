class SupportTicket::Suggestion
  attr_reader :title, :resource

  def initialize(title:, resource:)
    @title = title
    @resource = resource
  end
end
