class Support::BaseController < ApplicationController
  before_action :require_dfe_user!

private

  def require_dfe_user!
    if !SessionService.is_signed_in?(session)
      redirect_to_sign_in
    elsif !@current_user.is_support?
      render 'errors/forbidden', status: :forbidden
    end
  end
end
