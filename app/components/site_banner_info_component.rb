class SiteBannerInfoComponent < ViewComponent::Base
  def initialize
    @message_partial = Site.long_form_banner_message_flag? ? Site.long_form_site_banner_message_partial : nil
  end
end
