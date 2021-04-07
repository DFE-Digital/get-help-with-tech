Computacenter::TechSourceMaintenanceBannerComponent.class_eval do
  def render?
    true
  end
end

class Computacenter::TechSourceMaintenanceBannerComponentPreview < ViewComponent::Preview
  def displaying_notice
    render(Computacenter::TechSourceMaintenanceBannerComponent.new)
  end
end
