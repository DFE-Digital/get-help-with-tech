class ResponsibleBody::BaseController < ApplicationController
  before_action :require_signed_in!,
                :deny_single_academy_trust_user!,
                :require_rb_user!,
                :set_responsible_body

private

  def require_signed_in!
    redirect_to_sign_in unless SessionService.is_signed_in?(session)
  end

  def deny_single_academy_trust_user!
    render 'errors/forbidden', status: :forbidden if impersonated_or_current_user.single_school_user?
  end

  def require_rb_user!
    unless impersonated_or_current_user.responsible_body_user?
      render 'errors/forbidden', status: :forbidden
    end
  end

  def set_responsible_body
    @responsible_body = impersonated_or_current_user.responsible_body
  end
end
