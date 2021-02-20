class DonatedDeviceRequestSummaryListComponent < SummaryListComponent
  validates :donated_device_request, presence: true

  def initialize(donated_device_request:)
    @donated_device_request = donated_device_request
  end

  def rows
    [
      first_row,
      {
        key: 'Device types',
        value: device_list,
        action: 'Change',
        change_path: device_list_change_path,
      },
      {
        key: 'Preferred number',
        value: requested_units,
        action: 'Change',
        change_path: units_change_path,
      },
    ]
  end

private

  def first_row
    if @donated_device_request.responsible_body.present?
      {
        key: 'Opted in',
        value: school_names_or_all,
        action: 'Change',
        change_path: responsible_body_donated_devices_select_schools_path,
      }
    else
      {
        key: 'Delivery details',
        value: delivery_details,
      }
    end
  end

  def device_list_change_path
    if @donated_device_request.responsible_body.present?
      responsible_body_donated_devices_what_devices_do_you_want_path
    else
      what_devices_do_you_want_donated_devices_school_path(@donated_device_request.school)
    end
  end

  def units_change_path
    if @donated_device_request.responsible_body.present?
      responsible_body_donated_devices_how_many_devices_path
    else
      how_many_devices_donated_devices_school_path(@donated_device_request.school)
    end
  end

  def delivery_details
    [
      "<strong>#{@donated_device_request.user.full_name}</strong>",
      @donated_device_request.delivery_address,
    ].join('<br/>').html_safe
  end

  def device_list
    @donated_device_request.selected_devices_list
  end

  def requested_units
    @donated_device_request.number_of_devices_selected
  end

  def school_names_or_all
    if @donated_device_request.opt_in_all_schools?
      'All schools'
    else
      @donated_device_request.opted_in_school_names.join('<br/>').html_safe
    end
  end
end
