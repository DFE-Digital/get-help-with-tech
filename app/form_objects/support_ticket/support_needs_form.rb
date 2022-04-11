class SupportTicket::SupportNeedsForm
  include ActiveModel::Model

  attr_accessor :support_topics

  validate :must_have_a_support_topic

  def options_and_suggestions
    @options_and_suggestions ||= SupportTicket::OptionsService.call(Rails.configuration.support_tickets[:support_needs_options])
  end

  def support_needs_options
    options_and_suggestions.to_a
  end

  def selected_option_label(selected_value)
    options_and_suggestions.find_label(selected_value)
  end

private

  def must_have_a_support_topic
    if support_topics.blank? || support_topics.reject(&:blank?).blank?
      errors.add(:support_topics, :blank, message: 'Tell us what you need help with')
    end
  end
end
