class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  before_action :populate_user_from_session!

  include Pagy::Backend

private

  def populate_user_from_session!
    @user = User.find(session[:user_id]) if is_signed_in?
    @user ||= User.new
  end

  def save_user_to_session!(user = @user)
    session[:user_id] ||= user.id if user.present?
  end

  def is_signed_in?
    session[:user_id].present?
  end

  def require_sign_in!
    unless is_signed_in?
      redirect_to_sign_in
    end
  end

  def redirect_to_sign_in
    session[:return_url] = request.url
    flash[:error] = 'You must sign in to access that page'
    redirect_to new_sign_in_token_path
  end
end
