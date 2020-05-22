class ApplicationFormsController < ApplicationController
  def new
    @application_form = ApplicationForm.new(user: @user)
  end

  def create
    @application_form = ApplicationForm.new(params: application_form_params)
    begin
      @application_form.save!
      redirect_to application_form_success_path(@application_form)
    rescue ActiveModel::ValidationError => e
      render :new
    end
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
      :phone_network_name,
      :privacy_statement_sent_to_family,
      :understands_how_pii_will_be_used,
    )
  end
end
