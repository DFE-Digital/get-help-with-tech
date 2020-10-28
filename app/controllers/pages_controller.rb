class PagesController < ApplicationController
  layout 'single_page', only: %i[accessibility privacy]

  def guidance; end

  def bt_wifi_privacy_notice; end

  def increasing_mobile_data_privacy_notice; end

  def suggested_email_to_schools; end

  def start; end

  def home_page; end

  def about_increasing_mobile_data; end

  def accessibility; end

  def privacy; end

  def dfe_windows_privacy_notice; end

  def general_privacy_notice; end

  def request_a_change; end
end
