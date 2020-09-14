class ResponsibleBody::Devices::OrdersController < ResponsibleBody::Devices::BaseController
  def show
    if @responsible_body.has_any_schools_that_can_order_now?
      if @responsible_body.has_centrally_managed_schools_that_can_order_now?
        # at least 1 centrally managed school can order now
        # or mix of centrally managed and devolved
        @schools = @responsible_body.schools.that_are_centrally_managed.that_can_order_std_devices_now

        if @schools.that_are_ordering_for_lockdown.count.positive?
          render 'order_now'
        else
          render 'specific_circumstances'
        end
      else
        # must only be schools that order devices that can order now
        render 'cannot_order_yet'
      end
    else
      render 'cannot_order_yet'
    end
  end
end
