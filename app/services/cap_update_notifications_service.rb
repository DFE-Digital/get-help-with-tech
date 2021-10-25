class CapUpdateNotificationsService
  attr_reader :notify_computacenter, :notify_school, :updates

  def initialize(*schools, device_types:, notify_computacenter: true, notify_school: true)
    @notify_computacenter = notify_computacenter
    @notify_school = notify_school
    @updates = cap_updates(schools, device_types)
  end

  def call
    process_updates!
    true
  end

private

  def cap_updates(schools, device_types)
    cc_schools = schools.select(&:computacenter_references?)
    updates = device_types.map do |device_type|
      cc_schools.map { |school| cap_update(school, device_type) }
    end
    updates.flatten.sort_by(&:device_type)
  end

  def cap_update(school, device_type)
    OpenStruct.new(school: school, device_type: device_type)
  end

  def computacenter_accepts_updates?
    Settings.computacenter.outgoing_api&.endpoint.present?
  end

  def computacenter_cap_data
    updates.map do |update|
      device_type = update.device_type
      school = update.school
      OpenStruct.new(cap_type: Computacenter::CapTypeConverter.to_computacenter_type(device_type),
                     ship_to: school.computacenter_reference,
                     cap: school.computacenter_cap(device_type))
    end
  end

  def failed!
    body = request.response&.body
    status = request.response&.status
    message = "Computacenter responded with #{status}, response_body: #{body}"
    raise(Computacenter::OutgoingAPI::Error.new(cap_update_request: request), message)
  end

  def notify
    updates.each { |update| notify_computacenter_by_email(update.school, update.device_type) } if notify_computacenter
    notify_school_by_email(updates.first.school) if notify_school
  end

  def notify_computacenter_by_email(school, device_type)
    notification = device_type == :laptop ? :notify_of_devices_cap_change : :notify_of_comms_cap_change
    ComputacenterMailer.with(school: school, new_cap_value: school.cap(device_type)).send(notification).deliver_later
  end

  def notify_school_by_email(school)
    SchoolCanOrderDevicesNotifications.new(school: school, notify_computacenter: notify_computacenter).call
  end

  def process_updates!
    if updates.any? && computacenter_accepts_updates?
      update_cap_on_computacenter!
      notify
    end
  end

  def record_request!(school, device_type)
    school.cap_update_calls.create!(device_type: device_type,
                                    request_body: request.body,
                                    response_body: request.response&.body,
                                    failure: !request.success?)
  end

  def request
    @request ||= Computacenter::OutgoingAPI::CapUpdateRequest.new(cap_data: computacenter_cap_data).post
  end

  def update_cap_on_computacenter!
    updates.each do |update|
      update.school.timestamp_cap_update!(update.device_type, request.timestamp, request.payload_id) if request.success?
      record_request!(update.school, update.device_type)
    end
    request.success? || failed!
  end
end
