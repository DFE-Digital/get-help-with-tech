class Mno::BaseController < ApplicationController
  before_action :require_mno_user!, :set_mobile_network

private

  def require_mno_user!
    if session[:user_id].present?
      render 'errors/forbidden', status: :forbidden unless @user.is_mno_user?
    else
      redirect_to_sign_in
    end
  end

  def set_mobile_network
    @mobile_network = @user.mobile_network
  end
end
