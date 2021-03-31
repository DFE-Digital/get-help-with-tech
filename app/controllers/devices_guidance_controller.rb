class DevicesGuidanceController < ApplicationController
  before_action :show_parent_carer_pupil_banner?

  def index
    @responsible_body_pages = devices_guidance.pages_for(audience: :responsible_body_users)
    @setup_guide_pages = devices_guidance.pages_for(audience: :setup_guide_pages)
    @manage_devices_pages = devices_guidance.pages_for(audience: :manage_devices_pages)
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
        audience: page_metadata[:audience],
        noindex: page_metadata[:noindex],
      }
    end
  end

  def valid_subpage_slug?
    params[:subpage_slug].present? && devices_guidance.page_exists?(params[:subpage_slug])
  end
end
