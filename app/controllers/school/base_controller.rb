class School::BaseController < ApplicationController
  before_action :require_school_user!, :set_school

private

  def require_school_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless @user.is_school_user?
    else
      redirect_to_sign_in
    end
  end

  def set_school
    @school = @user.school
  end
end
