class Computacenter::BaseController < ApplicationController
  before_action :require_cc_user!

private

  def require_cc_user!
    if @user
      render 'errors/forbidden', status: :forbidden unless @user.is_computacenter?
    else
      redirect_to_sign_in
    end
  end
end
