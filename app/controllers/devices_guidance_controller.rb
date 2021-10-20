class DevicesGuidanceController < ApplicationController
  def index
    @before_you_order_pages = devices_guidance.pages_for(guidance_section: :before_you_order_pages)
    @setup_guide_pages = devices_guidance.pages_for(guidance_section: :setup_guide_pages)
    @manage_devices_pages = devices_guidance.pages_for(guidance_section: :manage_devices_pages)
    @replace_faulty_devices_pages = devices_guidance.pages_for(guidance_section: :replace_faulty_devices_pages)
  end

  def subpage
    if valid_subpage_slug?
      @page = devices_guidance.find_by_slug(params[:subpage_slug])
      render @page.page_id, layout: 'guidance_pages'
    else
      not_found
    end
  end

private

  def devices_guidance
    @devices_guidance ||= MultipartGuidance.new(guide_pages_metadata)
  end

  def guide_pages_metadata
    I18n.t!('devices_guidance').map do |page_id, page_metadata|
      {
        page_id: page_id,
        path: devices_guidance_subpage_path(subpage_slug: page_id.to_s.dasherize),
        title: page_metadata[:title],
        description: page_metadata[:description],
        guidance_section: page_metadata[:guidance_section],
        noindex: page_metadata[:noindex],
      }
    end
  end

  def valid_subpage_slug?
    params[:subpage_slug].present? && devices_guidance.page_exists?(params[:subpage_slug])
  end
end
