class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  http_basic_authenticate_with  name: Settings.http_basic_auth.username,
                                password: Settings.http_basic_auth.password,
                                if: -> { FeatureFlag.active?(:http_basic_auth) }

  before_action :populate_user_from_session!,
                :check_static_guidance_only_feature_flag!,
                :protect_against_host_header_poisoning

  include Pagy::Backend

private

  def populate_user_from_session!
    if SessionService.is_signed_in?(session)
      @user = User.find(session[:user_id])
      SessionService.update_session!(session[:session_id])
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
    redirect_to sign_in_path
  end

  def check_static_guidance_only_feature_flag!
    if FeatureFlag.active?(:static_guidance_only)
      render 'errors/not_found', status: :not_found unless %w[pages monitoring].include?(controller_name)
    end
  end

  # Pentest issue: Host Header Poisoning vulnerability
  def protect_against_host_header_poisoning
    %w[HTTP_HOST HTTP_X_FORWARDED_HOST].each do |header|
      if request.env[header] && \
          (request.env[header] != Settings.hostname_for_urls)
        request.env.delete(header)
      end
    end
  end
end
