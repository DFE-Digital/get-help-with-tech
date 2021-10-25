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
    School
      .where(who_will_order_devices: 'school', status: 'open')
      .sum('raw_laptop_cap - raw_laptops_ordered')
  end

  def remaining_from_managed_schools
    School
      .where(who_will_order_devices: 'responsible_body')
      .sum('raw_laptop_cap - raw_laptops_ordered')
  end
end
