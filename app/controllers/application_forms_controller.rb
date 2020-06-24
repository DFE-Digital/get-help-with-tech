class ApplicationFormsController < ApplicationController
  before_action :require_sign_in!

  def new
    @application_form = ApplicationForm.new
    @mobile_networks = MobileNetwork.order('LOWER(brand)')
  end

  def create
    @application_form = ApplicationForm.new(application_form_params.merge(created_by_user: @user))
    begin
      @application_form.save!
      redirect_to application_form_success_path(@application_form.recipient.id)
    rescue ActiveModel::ValidationError
      @mobile_networks = MobileNetwork.order('LOWER(brand)')
      render :new, status: :bad_request
    end
  end

  def success
    # NOTE: restful route expects :application_form_id, we're actually using it
    # to retrieve the recipient. Not good, need to refactor
    @application_form = ApplicationForm.new(recipient: Recipient.find(params[:application_form_id]))
  end

private

  def application_form_params
    params.require(:application_form).permit(
      :can_access_hotspot,
      :account_holder_name,
      :device_phone_number,
      :mobile_network_id,
      :privacy_statement_sent_to_family,
      :understands_how_pii_will_be_used,
    )
  end
end
