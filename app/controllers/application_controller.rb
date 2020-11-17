class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :identify_user!
  before_action :set_paper_trail_whodunnit

  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  protect_from_forgery unless: -> { request.format.json? || request.format.xml? }

  def hide_nav_menu?
    false
  end

private

  def user_for_paper_trail
    "#{identify_user!&.class}:#{identify_user!&.id}"
  end

  def identify_user!
    @user ||= (SessionService.identify_user!(session) || User.new)
    @current_user = @user # avoid conflicts in support/users_controller.rb
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

  def render_404_unless_school_in_mno_feature(school)
    unless school.mno_feature_flag
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
    elsif user.is_responsible_body_user?
      root_url_for_responsible_body(user)
    elsif user.is_school_user?
      school_root_url_for(user)
    elsif user.is_computacenter?
      computacenter_home_path
    elsif user.is_support?
      support_home_path
    else
      # this should not happen - so let's tell Sentry
      Raven.capture_message(
        "couldn't figure out root_url_for user",
        logger: 'logger',
        extra: {
          time_at: Time.zone.now,
          user_id: user.id,
        },
        tags: {
          env: Rails.env,
        },
      )
      '/'
    end
  end

  def root_url_for_responsible_body(user)
    if user.is_school_user?
      if user.is_a_single_academy_trust_user?
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
          user.school.preorder_information&.chromebook_info_still_needed?
        before_you_can_order_school_path(user.school)
      else
        home_school_path(user.schools.first)
      end
    else
      schools_path
    end
  end
end
