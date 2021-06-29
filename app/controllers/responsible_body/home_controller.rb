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

    if @responsible_body.has_virtual_cap_feature_flags?
      std_count = @responsible_body.std_device_pool&.devices_ordered.to_i
      coms_count = @responsible_body.coms_device_pool&.devices_ordered.to_i
    else
      @responsible_body.schools.each do |s|
        std_count += s.std_device_allocation&.devices_ordered.to_i
        coms_count += s.coms_device_allocation&.devices_ordered.to_i
      end
    end

    [std_count, coms_count]
  end

  def completed_requests_count
    @responsible_body.extra_mobile_data_requests.complete_status.size
  end
end
