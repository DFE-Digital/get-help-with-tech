class AllocationRequestFormsController < ApplicationController
  before_action :require_sign_in!

  def new
    @allocation_request_form = AllocationRequestForm.new
  end

  def create
    params_for_create = allocation_request_form_params.merge(
      created_by_user: @user,
    )
    @allocation_request_form = AllocationRequestForm.new(params_for_create)
    begin
      @allocation_request_form.save!
      redirect_to success_allocation_request_forms_path(@allocation_request_form.allocation_request.id)
    rescue ActiveModel::ValidationError
      render :new, status: :bad_request
    end
  end

  def success
    @allocation_request = @user.allocation_requests.find(params[:allocation_request_id])
    @allocation_request_form = AllocationRequestForm.new(allocation_request: @allocation_request)
  rescue ActiveRecord::RecordNotFound
    render template: 'errors/not_found', status: :not_found
  end

private

  def allocation_request_form_params
    params.require(:allocation_request_form).permit(
      :number_eligible,
      :number_eligible_with_hotspot_access,
    )
  end
end
