class Support::Devices::OrderStatusController < Support::BaseController
  before_action :set_school

  def edit
    @form = Support::EnableOrdersForm.new(enable_orders_form_params)
  end

  def update
    @form = Support::EnableOrdersForm.new(enable_orders_form_params)
    if @form.valid?
      CapUpdateService.new(school: @school).update!(cap: @form.cap, order_state: @form.order_state)
      flash[:success] = t(:success, scope: %i[support order_status update])
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  rescue Computacenter::OutgoingAPI::Error => e
    flash[:warning] = t(:cap_update_request_error, scope: %i[support order_status update], payload_id: e.cap_update_request&.payload_id)
    render :edit, status: :unprocessable_entity
  end

private

  def set_school
    @school = School.find_by_urn(params[:school_urn])
  end

  def enable_orders_form_params(opts = params)
    opts.fetch(:support_enable_orders_form, {}).permit(:order_state, :cap)
  end
end
