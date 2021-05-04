class SupportTicket::SupportNeedsForm
  include ActiveModel::Model

  attr_accessor :support_topics

  validate :must_have_a_support_topic

  OPTIONS = {
    'laptops_and_tablets' => 'Laptops and tablets',
    '4g_wireless_routers_and_internet_access' => '4G wireless routers and internet access',
    'digital_education_platforms' => 'Digital education platforms (Google Workspace for Education Fundamentals or Microsoft 365 Education)',
    'technology_training_and_support' => 'Technology training and support for schools and colleges',
    'something_else' => 'Something else',
  }.freeze

  def support_needs_options
    OPTIONS.map do |option_value, option_label|
      OpenStruct.new(
        value: option_value,
        label: option_label,
      )
    end
  end

  def selected_option_label(selected_value)
    OPTIONS[selected_value]
  end

private

  def must_have_a_support_topic
    if support_topics.blank? || support_topics.reject(&:blank?).blank?
      errors.add(:support_topics, :blank, message: 'Tell us what you need help with')
    end
  end
end
