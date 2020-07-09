class Mno::BaseController < ApplicationController
  before_action :check_extra_mobile_data_offer_feature_flag!,
                :require_mno_user!,
                :set_mobile_network

private

  def check_extra_mobile_data_offer_feature_flag!
    if FeatureFlag.inactive?(:extra_mobile_data_offer)
      render 'errors/not_found', status: :not_found
    end
  end

  def require_mno_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless @user.is_mno_user?
    else
      redirect_to_sign_in
    end
  end

  def set_mobile_network
    @mobile_network = @user.mobile_network
  end
end
