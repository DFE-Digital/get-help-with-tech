class PagesController < ApplicationController
  layout 'single_page', only: %i[accessibility privacy]

  def guidance; end

  def home_page
    @show_parent_carer_pupil_banner = false
  end

  def accessibility; end

  def privacy; end

  def dfe_windows_privacy_notice; end

  def general_privacy_notice; end

  def request_a_change; end

  def internet_access; end
end
