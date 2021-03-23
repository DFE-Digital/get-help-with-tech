class PagesController < ApplicationController
  before_action :show_parent_carer_pupil_banner?, except: %i[accessibility privacy]

  layout 'single_page', only: %i[accessibility privacy]

  def guidance; end

  def increasing_mobile_data_privacy_notice; end

  def home_page
    @show_parent_carer_pupil_banner = false
  end

  def about_increasing_mobile_data; end

  def accessibility; end

  def privacy; end

  def dfe_windows_privacy_notice; end

  def general_privacy_notice; end

  def request_a_change; end

  def internet_access; end
end
