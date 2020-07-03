class ResponsibleBody::BaseController < ApplicationController
  before_action :require_rb_user!, :set_responsible_body

private

  def require_rb_user!
    if SessionService.is_signed_in?(session)
      render 'errors/forbidden', status: :forbidden unless @user.is_responsible_body_user?
    else
      redirect_to_sign_in
    end
  end

  def set_responsible_body
    @responsible_body = @user.responsible_body
  end
end
