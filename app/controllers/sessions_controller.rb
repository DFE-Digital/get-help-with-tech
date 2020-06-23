class SessionsController < ApplicationController
  def destroy
    SessionService.destroy_session!(session[:session_id])
    reset_session
    request.env['HTTP_COOKIE'] = nil
    flash.notice = 'You have signed out succesfully'
    redirect_to '/'
  end
end
