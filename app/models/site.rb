# frozen_string_literal: true

class Site
  def self.banner_message
    @short_form_banner_message ||= Settings.site_banner_message.presence
  end

  def self.long_form_banner_message_flag?
    ActiveModel::Type::Boolean.new.cast(Settings.long_form_site_banner_message_flag&.to_s&.downcase) || false
  end

  def self.long_form_site_banner_message_partial
    Settings.long_form_site_banner_message_partial
  end
end
