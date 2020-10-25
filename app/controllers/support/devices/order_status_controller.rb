class Support::Devices::OrderStatusController < Support::BaseController
  before_action :set_school

  def edit
    @form = Support::EnableOrdersForm.new(existing_params.merge(enable_orders_form_params))
  end

  def update
    @form = Support::EnableOrdersForm.new(
      enable_orders_form_params.merge(device_allocation: @school.std_device_allocation),
    )
    if @form.valid?
      if params[:confirm].present?
        ActiveRecord::Base.transaction do
          SchoolOrderStateAndCapUpdateService.new(school: @school).update!(cap: @form.cap, order_state: @form.order_state)
        end
        flash[:success] = t(:success, scope: %i[support order_status update])
        redirect_to support_school_path(urn: @school.urn)
      else
        redirect_to support_devices_school_confirm_enable_orders_path(urn: @school.urn, order_state: @form.order_state, cap: @form.cap)
      end
    else
      render :edit, status: :unprocessable_entity
    end
  rescue Computacenter::OutgoingAPI::Error => e
    flash[:warning] = t(:cap_update_request_error, scope: %i[support order_status update], payload_id: e.cap_update_request&.payload_id)
    render :edit, status: :unprocessable_entity
  end

  # GET /support/devices/schools/:urn/enable-orders/confirm
  def confirm
    @form = Support::EnableOrdersForm.new(order_state: params[:order_state], cap: params[:cap])
    @allocation = @school.std_device_allocation.allocation
  end

private

  def set_school
    @school = School.find_by_urn(params[:school_urn])
  end

  def existing_params
    {
      order_state: @school.order_state,
      cap: device_allocation.cap,
    }
  end

  def device_allocation
    SchoolDeviceAllocation.find_or_initialize_by(school: @school, device_type: 'std_device')
  end

  def enable_orders_form_params(opts = params)
    opts.fetch(:support_enable_orders_form, {}).permit(:order_state, :cap)
  end
end
