class DonatedDeviceRequestPresenter < SimpleDelegator
  def available_device_types
    DonatedDeviceRequest::DEVICE_TYPES.map do |dt|
      OpenStruct.new(id: dt,
                     name: device_label(dt))
    end
  end

  def device_amount_options
    (1..4).map do |amount|
      OpenStruct.new(value: amount,
                     label: "#{amount * 5} devices")
    end
  end

  def selected_devices_list
    device_types.map { |dt| device_label(dt) }.join('<br/>').html_safe
  end

  def number_of_devices_selected
    "#{units * 5} devices" unless units.nil?
  end

  def delivery_address
    [school.name].concat(school.address_components).join('<br/>').html_safe
  end

  def school
    @school ||= School.find(schools.first)
  end

private

  def donated_device_request
    __getobj__
  end

  def device_label(device_type)
    I18n.t(device_type.to_s.underscore, scope: 'page_titles.school.donated_devices.interest.device_types.device_labels')
  end
end
