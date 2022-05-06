class SupportTicket::DescribeYourselfForm
  include ActiveModel::Model

  attr_accessor :user_type

  validates :user_type, presence: { message: 'Tell us which of these best describes you' }
  validates :user_type, inclusion: { in: %w[college
                                            local_authority
                                            multi_academy_trust
                                            other_type_of_user
                                            parent_or_guardian_or_carer_or_pupil_or_care_leaver
                                            school_or_single_academy_trust],
                                     message: 'Wrong user type' }

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
