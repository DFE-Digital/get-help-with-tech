class ResponsibleBody::Devices::OrdersController < ResponsibleBody::BaseController
  def show
    if @responsible_body.has_any_schools_that_can_order_now?
      if @responsible_body.has_centrally_managed_schools_that_can_order_now?
        # at least 1 centrally managed school can order now
        # or mix of centrally managed and devolved
        @schools = @responsible_body.schools.gias_status_open.that_are_centrally_managed.that_can_order_now.order(name: :asc)

        @schools_can_order = @schools.can_order
        @schools_can_order_for_specific_circumstances = @schools.can_order_for_specific_circumstances

        # There is no seperate 'specific circumstances' page if we're using virtual caps.
        if @responsible_body.has_virtual_cap_feature_flags? || @schools.can_order.count.positive?

          # There is no seperate 'cannot order anymore' page if we're not using virtual caps.
          if !@responsible_body.has_virtual_cap_feature_flags? || @responsible_body.devices_available_to_order?
            render 'order_devices'
          else
            render 'cannot_order_anymore'
          end
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
