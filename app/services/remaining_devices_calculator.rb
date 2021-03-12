class RemainingDevicesCalculator
  def current_unclaimed_totals
    RemainingDeviceCount.new(
      date_of_count: Time.zone.now,
      remaining_from_devolved_schools: remaining_from_devolved_schools,
      remaining_from_managed_schools: remaining_from_managed_schools,
    ).tap(&:valid?)
  end

  def remaining_from_devolved_schools
    remaining_amount_for(School.that_will_order_devices)
  end

  def remaining_from_managed_schools
    remaining_amount_for(School.that_are_centrally_managed)
  end

private

  def remaining_amount_for(school_ordering_type)
    SchoolDeviceAllocation
      .std_device
      .joins(:school)
      .merge(school_ordering_type)
      .where('devices_ordered < cap')
      .sum('cap - devices_ordered')
  end
end
