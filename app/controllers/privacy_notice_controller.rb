class PrivacyNoticeController < ApplicationController
  before_action :require_sign_in!

  def show; end

  def seen
    authorize impersonated_or_current_user, policy_class: PrivacyNoticePolicy

    impersonated_or_current_user.seen_privacy_notice!
    redirect_to root_url_for(impersonated_or_current_user)
  end
end
