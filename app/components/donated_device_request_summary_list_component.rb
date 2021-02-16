class DonatedDeviceRequestSummaryListComponent < SummaryListComponent
  validates :donated_device_request, presence: true

  def initialize(donated_device_request:)
    @donated_device_request = donated_device_request
    @school = donated_device_request.school
  end

  def rows
    [
      {
        key: 'Delivery details',
        value: delivery_details,
      },
      {
        key: 'Device types',
        value: device_list,
        action: 'Change',
        change_path: what_devices_do_you_want_donated_devices_school_path(@school),
      },
      {
        key: 'Preferred number',
        value: requested_units,
        action: 'Change',
        change_path: how_many_devices_donated_devices_school_path(@school),
      },
    ]
  end

private

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
end
