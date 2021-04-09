class Computacenter::TechSourceMaintenanceBannerComponentPreview < ViewComponent::Preview
  def displaying_notice
    @component = Computacenter::TechSourceMaintenanceBannerComponent.new
    @component.class_eval do
      def render?
        true
      end
    end

    render(@component)
  end
end
