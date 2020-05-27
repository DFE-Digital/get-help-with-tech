class AllocationRequestFormsController < ApplicationController
  def new
    @allocation_request_form = AllocationRequestForm.new(user: @user)
  end

  def create
    @allocation_request_form = AllocationRequestForm.new(user: @user, params: allocation_request_form_params)
    begin
      @allocation_request_form.save!
      save_user_to_session! unless session[:user_id] == @user.id
      redirect_to allocation_request_form_success_path(@allocation_request_form.allocation_request.id)
    rescue ActiveModel::ValidationError
      render :new, status: :bad_request
    end
  end

  def success
    # NOTE: restful route expects :application_form_id, we're actually using it
    # to retrieve the recipient. Not good, need to refactor
    @allocation_request_form = AllocationRequestForm.new(user: @user, allocation_request: AllocationRequest.find(params[:allocation_request_form_id]))
  end

private

  def allocation_request_form_params
    params.require(:allocation_request_form).permit(
      :user_name,
      :user_email,
      :user_organisation,
      :number_eligible,
      :number_eligible_with_hotspot_access,
    )
  end
end
