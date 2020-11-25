class Support::PerformanceData::SchoolsController < Support::PerformanceDataController
  include ActionController::Live

  def index
    response.headers['Content-Type'] = 'application/json'
    response.stream.write '['

    school_query.find_each.with_index do |school, index|
      response.stream.write ",\n" unless index.zero?
      response.stream.write attrs_for(school).to_json
    end

    response.stream.write ']'
    response.stream.close
  end

private

  def school_query
    School.includes(:preorder_information, :responsible_body, :std_device_allocation)
      .joins(:device_allocations)
      .merge(SchoolDeviceAllocation.included_in_performance_analysis)
  end

  def attrs_for(school)
    {
      school_name: school.name,
      school_urn: school.urn.to_s,
      responsible_body_name: school.responsible_body.name,
      responsible_body_gias_id: school.responsible_body.gias_id,
      responsible_body_companies_house_number: school.responsible_body.companies_house_number,
      allocation: school.std_device_allocation.allocation,
      cap: school.std_device_allocation.cap,
      devices_ordered: school.std_device_allocation.devices_ordered,
      coms_allocation: school.coms_device_allocation&.allocation,
      coms_cap: school.coms_device_allocation&.cap,
      coms_devices_ordered: school.coms_device_allocation&.devices_ordered,
      preorder_info_status: school.preorder_information&.status,
      school_order_state: school.order_state,
    }
  end
end
