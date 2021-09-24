class CapUpdateNotificationsService
  attr_reader :notify_computacenter, :notify_school, :allocations

  def initialize(*allocation_ids, notify_computacenter: true, notify_school: true)
    @notify_computacenter = notify_computacenter
    @notify_school = notify_school
    @allocations = SchoolDeviceAllocation.includes(school: :responsible_body)
                                         .where(id: allocation_ids)
                                         .order(:device_type, :id)
                                         .select(&:computacenter_references?)
  end

  def call
    process_allocations!
    true
  end

  private

  def computacenter_accepts_updates?
    Settings.computacenter.outgoing_api&.endpoint.present?
  end

  def computacenter_cap_data
    allocations.map do |allocation|
      OpenStruct.new(cap_type: allocation.computacenter_cap_type,
                     ship_to: allocation.computacenter_reference,
                     cap: allocation.computacenter_cap)
    end
  end

  def failed!(request)
    body = request.response&.body
    status = request.response&.status
    message = "Computacenter responded with #{status}, response_body: #{body}"
    raise(Computacenter::OutgoingAPI::Error.new(cap_update_request: request), message)
  end

  def notify
    allocations.each { |allocation| notify_computacenter_by_email(allocation) } if notify_computacenter
    notify_school_by_email(allocations.first.school) if notify_school
  end

  def notify_computacenter_by_email(allocation)
    notification = allocation.device_type == 'std_device' ? :notify_of_devices_cap_change : :notify_of_comms_cap_change
puts "--- Remove this debug info - Lorenzo: ComputacenterMailer.#{notification}.with(school: #{allocation.school.id}, new_cap_value: #{allocation.cap})"
    ComputacenterMailer.with(school: allocation.school, new_cap_value: allocation.cap).send(notification).deliver_later
  end

  def notify_school_by_email(school)
    SchoolCanOrderDevicesNotifications.new(school: school, notify_computacenter: notify_computacenter).call
  end

  def process_allocations!
    if allocations.any? && computacenter_accepts_updates?
      update_cap_on_computacenter!
      notify
    end
  end

  def record_request!(allocation)
    allocation.cap_update_calls.create!(request_body: request.body,
                                        response_body: request.response&.body,
                                        failure: !request.success?)
  end

  def request
    @request ||= Computacenter::OutgoingAPI::CapUpdateRequest.new(cap_data: computacenter_cap_data).post
  end

  def timestamp_cap_update!(allocation)
    allocation.update!(cap_update_request_timestamp: request.timestamp,
                       cap_update_request_payload_id: request.payload_id)
  end

  def update_cap_on_computacenter!
    allocations.each do |allocation|
      timestamp_cap_update!(allocation) if request.success?
      record_request!(allocation)
    end
    request.success? || failed!
  end
end
