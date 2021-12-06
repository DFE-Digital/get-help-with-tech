# frozen_string_literal: true

class Site
  def self.banner_message
    @banner_message ||= Settings.site_banner_message.presence
  end
end
