class DevicesGuidanceController < ApplicationController
  def subpage
    if valid_subpage_slug?
      @page = devices_guidance.find_by_slug(params[:subpage_slug])
      @next_page = { text: @page.next.title, path: @page.next.path } if @page.next.present?
      @prev_page = { text: @page.previous.title, path: @page.previous.path } if @page.previous.present?
    else
      not_found
    end
  end

private

  def devices_guidance
    @devices_guidance ||= DevicesGuidance.new
  end

  def valid_subpage_slug?
    params[:subpage_slug].present? && devices_guidance.page_exists?(params[:subpage_slug])
  end
end
