class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  http_basic_authenticate_with  name: ENV['HTTP_BASIC_AUTH_USERNAME'],
                                password: ENV['HTTP_BASIC_AUTH_PASSWORD'],
                                if: -> { FeatureFlag.active?(:http_basic_auth) }

  before_action :populate_user_from_session!,
                :check_static_guidance_only_feature_flag!

  include Pagy::Backend

private

  def populate_user_from_session!
    if SessionService.is_signed_in?(session)
      @user = User.find(session[:user_id])
      SessionService.update_session!(session[:session_id])
    else
      byebug
    end
    @user ||= User.new
  end

  def save_user_to_session!(user = @user)
    session[:user_id] ||= user.id
    SessionService.create_session!(session[:session_id])
  end

  def require_sign_in!
    redirect_to_sign_in unless SessionService.is_signed_in?(session)
  end

  def redirect_to_sign_in
    session[:return_url] = request.url
    flash[:error] = 'You must sign in to access that page'
    redirect_to new_sign_in_token_path
  end

  def check_static_guidance_only_feature_flag!
    if FeatureFlag.active?(:static_guidance_only)
      render 'errors/not_found', status: :not_found unless request.path == guidance_page_path
    end
  end
end
