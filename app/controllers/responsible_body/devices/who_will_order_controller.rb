class ResponsibleBody::Devices::WhoWillOrderController < ResponsibleBody::Devices::BaseController
  def edit
    @form = ResponsibleBody::Devices::WhoWillOrderForm.new(
      who_will_order: @responsible_body.who_will_order_devices
    )
  end

  def update
    @form = ResponsibleBody::Devices::WhoWillOrderForm.new(who_will_order_params)
    if @form.valid?
      @responsible_body.update!(who_will_order_devices: @form.who_will_order)
      flash[:notice] = I18n.t(:success, scope: %i[responsible_body devices who_will_order update success])
      redirect_to responsible_body_devices_who_will_order_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    
  end

private

  def who_will_order_params(opts = params)
    opts.require(:responsible_body_devices_who_will_order_form)
        .permit(:who_will_order)
  end
end
