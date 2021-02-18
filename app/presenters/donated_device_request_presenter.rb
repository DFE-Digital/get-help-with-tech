class DonatedDeviceRequestPresenter < SimpleDelegator
  attr_accessor :select_all

  def school_opt_in_options
    [
      OpenStruct.new(value: 'all_schools',
                     label: 'Opt in all'),
      OpenStruct.new(value: 'some_schools',
                     label: 'Opt in some'),
    ]
  end

  def schools_to_select_options
    schools_that_can_be_selected_now.order(name: :asc).pluck(:id, :name).map do |school|
      OpenStruct.new(value: school[0],
                     label: school[1])
    end
  end

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
    selected_device_names.join('<br/>').html_safe
  end

  def number_of_devices_selected
    unless units.nil?
      txt = [ "#{units * 5} devices" ]
      txt << 'per school or college' unless responsible_body.nil?
      txt.join(' ')
    end
  end

  def delivery_address
    [school.name].concat(school.address_components).join('<br/>').html_safe
  end

  def school
    @school ||= School.find(schools.first)
  end

  def opted_in_school_names
    School.where(id: schools).order(name: :asc).pluck(:name)
  end

  def selected_device_names
    device_types.map { |dt| device_label(dt) }
  end

  def schools_that_have_not_already_been_selected
    available_schools.where.not(id: schools).order(name: :asc)
  end

private

  def donated_device_request
    __getobj__
  end

  def device_label(device_type)
    I18n.t(device_type.to_s.underscore, scope: 'page_titles.donated_devices.device_labels')
  end

  def available_schools
    responsible_body.schools.gias_status_open.that_are_centrally_managed
  end

  def schools_that_can_be_selected_now
    if complete?
      schools_that_have_not_already_been_selected
    else
      available_schools
    end
  end
end
