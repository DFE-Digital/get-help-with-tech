class DevicesGuidanceController < ApplicationController
  before_action :show_parent_carer_pupil_banner?

  def index
    @responsible_body_pages = devices_guidance.pages_for(audience: :responsible_body_users)
    @device_user_pages = devices_guidance.pages_for(audience: :device_users)
  end

  def subpage
    if valid_subpage_slug?
      @page = devices_guidance.find_by_slug(params[:subpage_slug])
      @next_page = { text: @page.next.title, path: @page.next.path } if @page.next.present?
      @prev_page = { text: @page.previous.title, path: @page.previous.path } if @page.previous.present?
      render @page.page_id, layout: 'multipage_guide'
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
