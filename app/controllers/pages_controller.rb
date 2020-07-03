class PagesController < ApplicationController
  def guidance; end

  def bt_wifi_privacy_notice; end

  def suggested_email_to_schools; end

  def guide_to_collecting_mobile_information; end

  def about_increasing_mobile_data
    if FeatureFlag.active?(:static_guidance_only)
      render 'errors/not_found', status: :not_found
    end
  end
end
