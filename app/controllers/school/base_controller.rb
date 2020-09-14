class School::BaseController < ApplicationController
  before_action :require_school_user!, :set_school, :require_school!

private

  def require_school_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless @user.is_school_user?
    else
      redirect_to_sign_in
    end
  end

  def set_school
    if @user.schools.size == 1
      @school= @user.schools.first
    else
      # we want to let @school be nil if needed - the require_school! method
      # comes next in the chain and will handle that case
      @school = @user.schools.find_by_id(session[:school_id])
    end
  end

  def require_school!
    redirect_to user_organisations_path unless @school.present?
  end
end
