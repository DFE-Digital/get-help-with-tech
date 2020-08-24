class PagesController < ApplicationController
  layout 'single_page', only: :accessibility

  def guidance; end

  def bt_wifi_privacy_notice; end

  def increasing_mobile_data_privacy_notice; end

  def suggested_email_to_schools; end

  def start; end

  def about_increasing_mobile_data; end

  def accessibility; end

  def request_a_change; end
end
