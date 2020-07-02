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
      redirect_to success_application_forms_path(extra_mobile_data_request_id: @application_form.request.id)
    rescue ActiveModel::ValidationError
      @mobile_networks = MobileNetwork.order('LOWER(brand)')
      render :new, status: :bad_request
    end
  end

  def success
    @extra_mobile_data_request = @user.extra_mobile_data_requests.find(params[:extra_mobile_data_request_id])
    @application_form = ApplicationForm.new(extra_mobile_data_request: @extra_mobile_data_request)
  rescue ActiveRecord::RecordNotFound
    render template: 'errors/not_found', status: :not_found
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
