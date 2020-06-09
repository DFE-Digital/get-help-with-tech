# TODO: refactor this to have a Token Controller (more RESTful)
class SessionsController < ApplicationController
  def destroy
    reset_session
    request.env['HTTP_COOKIE'] = nil
    flash.notice = 'You have signed out succesfully'
    redirect_to '/'
  end
end
