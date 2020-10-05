class PrivacyNoticeController < ApplicationController
  before_action :require_sign_in!

  def show; end

  def seen
    @user.seen_privacy_notice!
    redirect_to root_url_for(@user)
  end
end
