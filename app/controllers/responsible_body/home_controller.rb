class ResponsibleBody::HomeController < ResponsibleBody::BaseController
  def show
    @std_count, @coms_count = device_count
    @completed_requests_count = completed_requests_count

    @has_ordered_std_devices = @std_count.positive?
    @has_ordered_coms_devices = @coms_count.positive?
    @has_ordered = @has_ordered_std_devices || @has_ordered_coms_devices
    @has_completed_extra_mobile_data_requests = @completed_requests_count.positive?
  end

private

  def device_count
    std_count = 0
    coms_count = 0

    if @responsible_body.vcap_active?
      std_count = @responsible_body.devices_ordered(:laptop)
      coms_count = @responsible_body.devices_ordered(:router)
    else
      std_count = @responsible_body.schools.sum { |school| school.devices_ordered(:laptop) }
      coms_count = @responsible_body.schools.sum { |school| school.devices_ordered(:router) }
    end

    [std_count, coms_count]
  end

  def completed_requests_count
    @responsible_body.extra_mobile_data_requests.complete_status.size
  end
end
