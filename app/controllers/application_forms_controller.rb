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
      redirect_to success_application_forms_path(recipient_id: @application_form.recipient.id)
    rescue ActiveModel::ValidationError
      @mobile_networks = MobileNetwork.order('LOWER(brand)')
      render :new, status: :bad_request
    end
  end

  def success
    @recipient = Recipient.where(id: params[:recipient_id], created_by_user_id: @user.id).first
    if @recipient
      @application_form = ApplicationForm.new(recipient: @recipient)
    else
      render template: 'errors/not_found', status: :not_found
    end
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
