class SiteBannerComponent < ViewComponent::Base
  def initialize(message: nil)
    @message = message
  end
end
