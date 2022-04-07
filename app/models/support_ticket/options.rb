class SupportTicket::Options
  attr_reader :options

  def initialize(options: [])
    @options = options
  end

  def find_label(value)
    @options.find { |option| option.value == value }&.label
  end

  def to_a
    @options
  end

  def to_h
    @options.each_with_object({}) do |option, hash|
      hash[option.value] = option.label
    end
  end
end
