class School::HomeController < School::BaseController
  def show
    @assistance_count = assistance_count
    @has_ordered = school.has_ordered?
    @in_vcap_pool = school.in_virtual_cap_pool?
  end

private

  def assistance_count
    [
      has_ordered_routers?,
      has_ordered_laptops?,
      has_completed_extra_mobile_data_requests?,
    ].count(true)
  end

  def completed_requests_count
    @completed_requests_count = school.completed_requests_count
  end

  def router_count
    @router_count ||= school.devices_ordered(:router)
  end

  def has_completed_extra_mobile_data_requests?
    @has_completed_extra_mobile_data_requests = completed_requests_count.positive?
  end

  def has_ordered_routers?
    @has_ordered_routers = router_count.positive?
  end

  def has_ordered_laptops?
    @has_ordered_laptops = laptop_count.positive?
  end

  def laptop_count
    @laptop_count = school.devices_ordered(:laptop)
  end
end
