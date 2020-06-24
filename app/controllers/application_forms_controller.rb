class ApplicationFormsController < ApplicationController
  before_action :require_sign_in!
  
  def new
    @application_form = ApplicationForm.new(user: @user)
    @mobile_networks = MobileNetwork.order('LOWER(brand)')
  end

  def create
    @application_form = ApplicationForm.new(user: @user, params: application_form_params)
    begin
      @application_form.save!
      @user = @application_form.user
      save_user_to_session! unless SessionService.is_signed_in?(session)
      redirect_to application_form_success_path(@application_form.recipient.id)
    rescue ActiveModel::ValidationError
      @mobile_networks = MobileNetwork.order('LOWER(brand)')
      render :new, status: :bad_request
    end
  end

  def success
    # NOTE: restful route expects :application_form_id, we're actually using it
    # to retrieve the recipient. Not good, need to refactor
    @application_form = ApplicationForm.new(user: @user, recipient: Recipient.find(params[:application_form_id]))
  end

private

  def application_form_params
    params.require(:application_form).permit(
      :user_name,
      :user_email,
      :user_organisation,
      :full_name,
      :address,
      :postcode,
      :can_access_hotspot,
      :is_account_holder,
      :account_holder_name,
      :device_phone_number,
      :mobile_network_id,
      :privacy_statement_sent_to_family,
      :understands_how_pii_will_be_used,
    )
  end
end
