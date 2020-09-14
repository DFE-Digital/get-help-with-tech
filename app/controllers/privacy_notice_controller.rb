class PrivacyNoticeController < ApplicationController
  before_action :require_sign_in!

  def show; end

  def seen
    @user.seen_privacy_notice!
    redirect_to next_url
  end

private

  def next_url
    if @user.user_organisations.size > 1
      user_organisations_path
    else
      root_url_for(@user)
    end
  end
end
