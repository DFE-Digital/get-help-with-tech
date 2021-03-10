class SupportTicket::DescribeYourselfForm
  include ActiveModel::Model

  attr_accessor :user_type

  validates :user_type, presence: { message: 'Tell us which of these best describes you' }

  OPTIONS = {
    school_or_single_academy_trust: 'I work for a school or single-academy trust',
    multi_academy_trust: 'I work for a multi-academy trust',
    local_authority: 'I work for a local authority',
    college: 'I work for a college',
    parent_or_guardian_or_carer_or_pupil_or_care_leaver: 'I’m a parent, guardian, pupil or care leaver',
    other_type_of_user: 'I’m none of the above',
  }.freeze

  def describe_yourself_options
    OPTIONS.map do |option_value, option_label|
      OpenStruct.new(
        value: option_value,
        label: option_label,
      )
    end
  end

  def selected_option_label(selected_value)
    OPTIONS[selected_value.to_sym]
  end

  def to_params
    {
      user_type: user_type,
    }
  end
end
