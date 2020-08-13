class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :populate_user_from_session_or_api_token!

  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  protect_from_forgery unless: -> { request.format.json? || request.format.xml? }

  def hide_nav_menu?
    false
  end

private

  def populate_user_from_session_or_api_token!
    @user ||= (SessionService.identify_user!(session) || APIAuthenticationService.identify_user(request) || User.new)
  end

  def save_user_to_session!(user = @user)
    # prevent duplicate key errors if they're already signed_in
    SessionService.destroy_session!(session[:session_id]) if session[:session_id]
    session[:user_id] = user.id
    SessionService.create_session!(session_id: session[:session_id], user: user)
  end

  def require_sign_in!
    redirect_to_sign_in unless SessionService.is_signed_in?(session)
  end

  def redirect_to_sign_in
    session[:return_url] = request.url
    flash[:error] = 'You must sign in to access that page'
    redirect_to sign_in_path
  end

  def render_404_if_feature_flag_inactive(feature_flag)
    if FeatureFlag.inactive?(feature_flag)
      render 'errors/not_found', status: :not_found and return
    end
  end

  def not_found
    render 'errors/not_found', status: :not_found and return
  end
end
