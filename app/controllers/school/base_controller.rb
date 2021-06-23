class School::BaseController < ApplicationController
  before_action :require_school_user!, :set_school

private

  def require_school_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless impersonated_or_current_user.is_school_user?
    else
      redirect_to_sign_in
    end
  end

  def set_school
    @school = impersonated_or_current_user.schools.where_urn_or_ukprn_or_provision_urn(params[:urn]).first!
  end
end
