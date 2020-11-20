class Computacenter::BaseController < ApplicationController
  include Pundit

  before_action :require_cc_user!

private

  def require_cc_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless @current_user.is_computacenter?
    else
      redirect_to_sign_in
    end
  end

  attr_reader :current_user
  helper_method :current_user
end
