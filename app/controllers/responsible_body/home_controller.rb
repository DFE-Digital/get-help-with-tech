class ResponsibleBody::HomeController < ResponsibleBody::BaseController
  attr_reader :responsible_body

  DEVICE_TYPES = %i[laptop router].freeze

  def show
    @laptop_count, @router_count = device_count
    @completed_requests_count = completed_requests_count

    @has_ordered_laptops = @laptop_count.positive?
    @has_ordered_routers = @router_count.positive?
    @has_ordered = @has_ordered_laptops || @has_ordered_routers
    @has_completed_extra_mobile_data_requests = @completed_requests_count.positive?
  end

private

  def device_count
    responsible_body.vcap? ? devices_ordered_by_vcap_schools : devices_ordered_by_schools
  end

  def devices_ordered_by_schools
    DEVICE_TYPES.map do |device_type|
      responsible_body.schools.sum { |school| school.devices_ordered(device_type) }
    end
  end

  def devices_ordered_by_vcap_schools
    DEVICE_TYPES.map { |device_type| responsible_body.devices_ordered(device_type) }
  end

  def completed_requests_count
    @responsible_body.extra_mobile_data_requests.complete_status.size
  end
end
