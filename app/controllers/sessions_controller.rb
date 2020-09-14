class SessionsController < ApplicationController
  def destroy
    SessionService.destroy_session!(session[:session_id])
    reset_session
    request.env['HTTP_COOKIE'] = nil
    flash.notice = 'You have signed out succesfully'
    redirect_to '/'
  end

  def sign_in_as_organisation
    @user_organisation = @user.user_organisations.find(user_organisation_params[:user_organisation_id])
    if @user_organisation.organisation.is_a?(School)
      session[:school_id] = @user_organisation.organisation_id
      redirect_to root_url_for(@user)
    elsif @user_organisation.organisation.is_a?(ResponsibleBody)
      session[:responsible_body_id] = @user_organisation.organisation_id
      redirect_to root_url_for(@user)
    else
      render 'errors/unprocessable_entity', status: :unprocessable_entity
    end
  end

private

  def user_organisation_params
    params.require(:sign_in_as_user_organisation_form).permit(:user_organisation_id)
  end
end
