class School::HomeController < School::BaseController
  def show
    @has_ordered = has_ordered?
    @has_ordered_std_devices = has_ordered_std_devices?
    @has_ordered_coms_devices = has_ordered_coms_devices?
    @has_completed_extra_mobile_data_requests = has_completed_extra_mobile_data_requests?

    @std_count = std_count
    @coms_count = coms_count
    @completed_requests_count = completed_requests_count

    @assistance_count = assistance_count

    @in_vcap_pool = @school.in_virtual_cap_pool?
  end

private

  def std_count
    @school.std_device_allocation&.devices_ordered.to_i
  end

  def coms_count
    @school.coms_device_allocation&.devices_ordered.to_i
  end

  def completed_requests_count
    if @school.in_virtual_cap_pool?
      @school.responsible_body.extra_mobile_data_requests.complete_status.size
    else
      @school.extra_mobile_data_requests.complete_status.size
    end
  end

  def has_ordered?
    @school.has_ordered?
  end

  def has_ordered_std_devices?
    std_count.positive?
  end

  def has_ordered_coms_devices?
    coms_count.positive?
  end

  def has_completed_extra_mobile_data_requests?
    completed_requests_count.positive?
  end

  def assistance_count
    [
      @has_ordered_std_devices,
      @has_ordered_coms_devices,
      @has_completed_extra_mobile_data_requests,
    ].count { |h| h == true }
  end
end
