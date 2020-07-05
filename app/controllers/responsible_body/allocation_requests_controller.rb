class ResponsibleBody::AllocationRequestsController < ResponsibleBody::BaseController
  def new_or_edit
    @allocation_request = @user.responsible_body.allocation_request || AllocationRequest.new
    if session[:allocation_request_params] # used for making the change links work
      @allocation_request.assign_attributes(session[:allocation_request_params])
      session.delete(:allocation_request_params)
    end
  end

  def check_your_answers
    @allocation_request = AllocationRequest.new(
      allocation_request_params.merge(
        responsible_body: @user.responsible_body,
        created_by_user: @user,
      ),
    )
    if @allocation_request.valid?
      # store given params in session, so that we don't have to pass them back in the URL
      # if the user clicks 'Change'
      session[:allocation_request_params] = allocation_request_params
    else
      render :new_or_edit, status: :bad_request
    end
  end

  def create_or_update
    allocation_request = @user.responsible_body.allocation_request || AllocationRequest.new
    allocation_request.assign_attributes(
      allocation_request_params.merge(
        responsible_body: @user.responsible_body,
        created_by_user: @user,
      ),
    )
    allocation_request.save!
    redirect_to responsible_body_home_path
  end

private

  def allocation_request_params
    params.require(:allocation_request).permit(
      :number_eligible,
      :number_eligible_with_hotspot_access,
    )
  end
end
