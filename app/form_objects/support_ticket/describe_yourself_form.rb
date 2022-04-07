class SupportTicket::DescribeYourselfForm
  include ActiveModel::Model

  attr_accessor :user_type

  validates :user_type, presence: { message: 'Tell us which of these best describes you' }

  VALID_SETTING_SUGGESTIONS = [
    { title: 'How to access the Get help with technology service', resource: :how_to_access_the_get_help_with_technology_service },
    { title: 'Who could get laptops and tablets, and why DfE provided them', resource: :what_to_do_if_you_cannot_get_laptops_tablets_or_internet_access_from_dfe },
    { title: 'How laptops and tablets were allocated', resource: '/devices/device-allocations' },
    { title: 'Who owns the devices', resource: '/devices/device-distribution-and-ownership' },
  ].freeze

  NON_SETTING_SUGGESTIONS = [
    { title: 'How to access the Get help with technology service', resource: :how_to_access_the_get_help_with_technology_service },
  ].freeze

  OPTIONS = [
    { value: :school_or_single_academy_trust, label: 'I work for a school or single-academy trust', suggestions: VALID_SETTING_SUGGESTIONS },
    { value: :multi_academy_trust, label: 'I work for a multi-academy trust', suggestions: VALID_SETTING_SUGGESTIONS },
    { value: :local_authority, label: 'I work for a local authority', suggestions: VALID_SETTING_SUGGESTIONS },
    { value: :college, label: 'I work for a college', suggestions: VALID_SETTING_SUGGESTIONS },
    { value: :parent_or_guardian_or_carer_or_pupil_or_care_leaver, label: 'I’m a parent, guardian, pupil or care leaver', suggestions: NON_SETTING_SUGGESTIONS },
    { value: :other_type_of_user, label: 'I’m none of the above', suggestions: NON_SETTING_SUGGESTIONS },
  ].freeze

  def options_and_suggestions
    @options_and_suggestions ||= SupportTicket::OptionsService.call(OPTIONS)
  end

  def describe_yourself_options
    options_and_suggestions.to_a
  end

  def selected_option_label(selected_value)
    options_and_suggestions.find_label(selected_value)
  end

  def to_params
    {
      user_type: user_type,
    }
  end
end
