class DevicesGuidanceController < ApplicationController
  def subpage
    not_found and return unless valid_subpage_slug?

    @page = devices_guidance.find_by_slug(params[:subpage_slug])

    render :rendered_markdown_template
  end

private

  def devices_guidance
    @devices_guidance ||= DevicesGuidance.new
  end

  def valid_subpage_slug?
    params[:subpage_slug].present? && devices_guidance.page_exists?(params[:subpage_slug])
  end
end
