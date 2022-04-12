class SupportTicket::DescribeYourselfForm
  include ActiveModel::Model

  attr_accessor :user_type

  validates :user_type, presence: { message: 'Tell us which of these best describes you' }

  def options_and_suggestions
    @options_and_suggestions ||= SupportTicket::OptionsService.call(Rails.configuration.support_tickets[:describe_yourself_options])
  end

  def describe_yourself_options
    options_and_suggestions.to_a
  end

  def selected_option_label(selected_value)
    options_and_suggestions.find_label(selected_value)
  end

  def to_params
    {
      user_type: user_type.to_s.parameterize,
    }
  end
end
