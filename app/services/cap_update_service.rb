class CapUpdateService
  attr_accessor :school, :device_type

  def initialize(args = {})
    @school = args[:school]
    @device_type = args[:device_type] || 'std_device'
  end

  def update!(order_state:, cap:)
    update_order_state!(order_state)
    allocation = update_cap!(cap)

    update_cap_on_computacenter!(allocation.id)

    notify_computacenter_by_email(allocation.cap)
  end

private

  def notify_computacenter_by_email(new_cap_value)
    if FeatureFlag.active?(:notify_computacenter_of_cap_changes)
      if @device_type == 'std_device'
        ComputacenterMailer.with(school: @school, new_cap_value: new_cap_value)
          .notify_of_devices_cap_change.deliver_later
      else
        ComputacenterMailer.with(school: @school, new_cap_value: new_cap_value)
          .notify_of_comms_cap_change.deliver_later
      end
    end
  end

  def update_order_state!(order_state)
    @school.update!(order_state: order_state)
  end

  def update_cap!(cap)
    allocation = SchoolDeviceAllocation.find_or_initialize_by(school_id: @school.id, device_type: @device_type)
    # we only take the cap from the user if they chose specific circumstances
    # for both other states, we need to infer a new cap from the chosen state
    allocation.cap = allocation.cap_implied_by_order_state(order_state: @school.order_state, given_cap: cap)
    allocation.save!
    allocation
  end

  def update_cap_on_computacenter!(allocation_id)
    api_request = Computacenter::OutgoingAPI::CapUpdateRequest.new(allocation_ids: [allocation_id])
    api_request.post!
  end
end
