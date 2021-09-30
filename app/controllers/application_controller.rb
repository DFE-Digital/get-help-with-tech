class ApplicationController < ActionController::Base
  include Pundit

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :identify_user!
  before_action :set_sentry_user
  before_action :set_paper_trail_whodunnit

  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery unless: -> { request.format.json? || request.format.xml? }

  def hide_nav_menu?
    false
  end

private

  def user_for_paper_trail
    "#{identify_user!&.class}:#{identify_user!&.id}"
  end

  def identify_user!
    @current_user ||= (SessionService.identify_user!(session) || User.new)
  end

  def set_sentry_user
    Sentry.set_user(id: current_user&.id)
  end

  def impersonated_user
    @impersonated_user = if session[:impersonated_user_id].blank?
                           nil
                         else
                           User.find_by(id: session[:impersonated_user_id])
                         end
  end
  helper_method :impersonated_user

  attr_reader :current_user

  helper_method :current_user

  def impersonated_or_current_user
    impersonated_user || current_user
  end
  helper_method :impersonated_or_current_user

  def save_user_to_session!(user = @current_user)
    # prevent duplicate key errors if they're already signed_in
    SessionService.destroy_session!(session[:session_id]) if session[:session_id]
    session[:user_id] = user.id
    SessionService.create_session!(session_id: session[:session_id], user: user)
  end

  def require_sign_in!
    redirect_to_sign_in unless SessionService.is_signed_in?(session)
  end

  def user_not_authorized
    render 'errors/forbidden', status: :forbidden
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

  def render_404_unless_responsible_body_has_connectivity_feature_flags(responsible_body)
    unless responsible_body.has_connectivity_feature_flags?
      render 'errors/not_found', status: :not_found and return
    end
  end

  def not_found
    render 'errors/not_found', status: :not_found and return
  end

  def root_url_for(user)
    if user.needs_to_see_privacy_notice? && !user.seen_privacy_notice?
      privacy_notice_path
    elsif user.is_mno_user?
      mno_extra_mobile_data_requests_path
    elsif user.responsible_body_user?
      root_url_for_responsible_body(user)
    elsif user.is_school_user?
      school_root_url_for(user)
    elsif user.is_computacenter?
      computacenter_home_path
    elsif user.is_support?
      support_home_path
    else
      # this should not happen - so let's tell Sentry
      Sentry.with_scope do |scope|
        scope.set_context('ApplicationController#root_url_for', { user_id: user.id })

        Sentry.capture_message("Couldn't figure out root_url_for user")
      end

      '/'
    end
  end

  def root_url_for_responsible_body(user)
    if user.is_school_user?
      if user.single_school_user?
        school_root_url_for(user)
      else
        schools_path
      end
    else
      responsible_body_home_path
    end
  end

  def school_root_url_for(user)
    if user.schools.size == 1
      if user.school.preorder_information&.school_will_order_devices? &&
          user.school.preorder_information&.chromebook_info_still_needed? &&
          !user.school.la_funded_provision?
        before_you_can_order_school_path(user.school)
      else
        home_school_path(user.schools.first)
      end
    else
      schools_path
    end
  end

  # Log the user identification params to help debug intermittent issue
  # [1277](https://trello.com/c/uIDcEmGH/1277-mno-bug-for-providers)
  def append_info_to_payload(payload)
    super
    payload[:current_user_id] = @current_user&.id
    payload[:session_user_id] = session[:user_id]
    payload[:session_id] = session[:session_id]
    payload[:request_id] = request.request_id
  end
end
