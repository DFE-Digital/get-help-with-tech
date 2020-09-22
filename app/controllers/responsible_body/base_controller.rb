class ResponsibleBody::BaseController < ApplicationController
  before_action :require_signed_in!,
                :deny_hybrid_user!,
                :require_rb_user!,
                :set_responsible_body

private

  def require_signed_in!
    redirect_to_sign_in unless SessionService.is_signed_in?(session)
  end

  def deny_hybrid_user!
    render 'errors/forbidden', status: :forbidden if @user.hybrid?
  end

  def require_rb_user!
    unless @user.is_responsible_body_user?
      render 'errors/forbidden', status: :forbidden
    end
  end

  def set_responsible_body
    @responsible_body = @user.responsible_body
  end
end
