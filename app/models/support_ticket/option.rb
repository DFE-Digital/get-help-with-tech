class SupportTicket::Option
  attr_reader :value, :label, :suggestions

  def initialize(value, label, suggestions: nil)
    @value = value.to_sym
    @label = label
    @suggestions = suggestions
  end
end
