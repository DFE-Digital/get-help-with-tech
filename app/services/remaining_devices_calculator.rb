class RemainingDevicesCalculator
  def current_unclaimed_totals
    RemainingDeviceCount.new(
      date_of_count: Time.zone.now,
      remaining_from_devolved_schools: remaining_from_devolved_schools,
      remaining_from_managed_schools: remaining_from_managed_schools,
    ).tap(&:valid?)
  end

private

  def remaining_from_devolved_schools
    SchoolDeviceAllocation
      .std_device
      .joins(school: :preorder_information)
      .where(preorder_information: { who_will_order_devices: 'school' })
      .where(school: { status: 'open'})
      .sum('cap - devices_ordered')
  end

  def remaining_from_managed_schools
    SchoolDeviceAllocation
      .std_device
      .joins(school: :preorder_information)
      .where(preorder_information: { who_will_order_devices: 'responsible_body' })
      .sum('cap - devices_ordered')
  end
end
