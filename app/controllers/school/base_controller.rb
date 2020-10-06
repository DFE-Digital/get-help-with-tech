class School::BaseController < ApplicationController
  before_action :require_school_user!, :set_school, :require_completed_welcome_wizard!

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

  def require_completed_welcome_wizard!
    unless @user.school_welcome_wizards.find_by_school_id(@school.id)&.complete? || params[:controller] == 'school/welcome_wizard'
      redirect_to school_welcome_wizard_allocation_path
    end
  end
end
