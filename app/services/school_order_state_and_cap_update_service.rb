class SchoolOrderStateAndCapUpdateService
  attr_accessor :school, :device_type

  def initialize(args = {})
    @school = args[:school]
    @device_type = args[:device_type] || 'std_device'
  end

  def update!(order_state:, cap:)
    update_order_state!(order_state)
    allocation = update_cap!(cap)

    if notify_computacenter_of_cap_changes?
      update_cap_on_computacenter!(allocation.id)
      notify_computacenter_by_email(allocation.cap)
    end

    # ensure the updates are picked up
    @school.std_device_allocation&.reload
    @school.coms_device_allocation&.reload

    # notifying users should only happen after successful completion of the Computacenter
    # cap update, because it's possible for that to fail and the whole thing
    # is rolled back
    CanOrderDevicesNotifications.new(school: school).call
  end

private

  def notify_computacenter_of_cap_changes?
    Settings.computacenter.outgoing_api.endpoint.present?
  end

  def notify_computacenter_by_email(new_cap_value)
    mailer = ComputacenterMailer.with(school: @school, new_cap_value: new_cap_value)
    if @device_type == 'std_device'
      mailer.notify_of_devices_cap_change.deliver_later
    else
      mailer.notify_of_comms_cap_change.deliver_later
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
    response = api_request.post!
    SchoolDeviceAllocation.where(id: allocation_id).update_all(
      cap_update_request_timestamp: api_request.timestamp,
      cap_update_request_payload_id: api_request.payload_id,
    )
    response
  end
end
