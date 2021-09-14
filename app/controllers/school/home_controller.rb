class School::HomeController < School::BaseController
  def show
    @assistance_count = assistance_count
    @has_ordered = school.has_ordered?
    @in_vcap_pool = school.in_virtual_cap_pool?
  end

  private

  def assistance_count
    [
      has_ordered_coms_devices?,
      has_ordered_std_devices?,
      has_completed_extra_mobile_data_requests?,
    ].count(true)
  end

  def completed_requests_count
    @completed_requests_count = school.completed_requests_count
  end

  def coms_count
    @coms_count ||= school.routers_ordered
  end

  def has_completed_extra_mobile_data_requests?
    @has_completed_extra_mobile_data_requests = completed_requests_count.positive?
  end

  def has_ordered_coms_devices?
    @has_ordered_coms_devices = coms_count.positive?
  end

  def has_ordered_std_devices?
    @has_ordered_std_devices = std_count.positive?
  end

  def std_count
    @std_count = school.laptops_ordered.to_i
  end
end
