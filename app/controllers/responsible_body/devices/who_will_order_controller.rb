class ResponsibleBody::Devices::WhoWillOrderController < ResponsibleBody::BaseController
  def edit
    authorize ResponsibleBody::Devices::WhoWillOrderForm, policy_class: ResponsibleBody::BasePolicy
    @form = ResponsibleBody::Devices::WhoWillOrderForm.new(
      who_will_order: @responsible_body.who_will_order_devices,
    )
  end

  def update
    authorize ResponsibleBody::Devices::WhoWillOrderForm, policy_class: ResponsibleBody::BasePolicy

    @form = ResponsibleBody::Devices::WhoWillOrderForm.new(who_will_order_params)
    if @form.valid?
      ResponsibleBody.transaction do
        @responsible_body.update_who_will_order_devices(@form.who_will_order)
      end

      event = WhoWillOrderEvent.new(responsible_body: @responsible_body)
      EventNotificationsService.broadcast(event)
      flash[:success] = I18n.t(:success, scope: %i[responsible_body devices who_will_order update])
      redirect_to responsible_body_devices_who_will_order_path
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing
    @form = ResponsibleBody::Devices::WhoWillOrderForm.new
    render :edit, status: :unprocessable_entity
  end

  def show; end

private

  def who_will_order_params
    params.require(:responsible_body_devices_who_will_order_form).permit(:who_will_order)
  end
end
