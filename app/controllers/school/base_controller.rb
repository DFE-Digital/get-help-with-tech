class School::BaseController < ApplicationController
  before_action :require_school_user!, :set_school, :require_completed_welcome_wizard!

private

  def require_school_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless impersonated_or_current_user.is_school_user?
    else
      redirect_to_sign_in
    end
  end

  def set_school
    @school = impersonated_or_current_user.schools.where_urn_or_ukprn(params[:urn].to_i).first!
  end

  def require_completed_welcome_wizard!
    unless impersonated_or_current_user.welcome_wizard_for(@school)&.complete? || params[:controller] == 'school/welcome_wizard'
      redirect_to welcome_wizard_allocation_school_path(@school)
    end
  end
end
