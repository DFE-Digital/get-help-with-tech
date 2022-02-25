class PagesController < ApplicationController
  layout 'single_page', only: %i[accessibility privacy]

  def guidance; end

  def home_page
    @show_parent_carer_pupil_banner = false
  end

  def accessibility; end

  def privacy; end

  def dfe_windows_privacy_notice; end

  def finding_out_about_internet_access_needs; end

  def general_privacy_notice; end

  def internet_access
    redirect_to root_path
  end

  def managing_your_4g_wireless_routers; end

  def request_a_change; end
end
