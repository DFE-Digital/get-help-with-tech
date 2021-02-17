class Support::PerformanceData::SchoolsController < Support::PerformanceDataController
  include ActionController::Live

  def index
    response.headers['Content-Type'] = 'application/json'
    response.stream.write '['

    School.connection.select_all(school_query).each_with_index do |row, index|
      response.stream.write ",\n" unless index.zero?
      response.stream.write row.to_json
    end

    response.stream.write ']'
    response.stream.close
  end

private

  def school_query
    <<-SQL
      SELECT  schools.name AS school_name,
              CAST(schools.urn AS TEXT) AS school_urn,
              schools.order_state AS school_order_state,
              responsible_bodies.name AS responsible_body_name,
              responsible_bodies.gias_id AS responsible_body_gias_id,
              responsible_bodies.companies_house_number AS responsible_body_companies_house_number,
              std_device_allocation.allocation,
              std_device_allocation.cap,
              std_device_allocation.devices_ordered,
              coms_device_allocation.allocation AS coms_allocation,
              coms_device_allocation.cap AS coms_cap,
              coms_device_allocation.devices_ordered AS coms_devices_ordered,
              preorder_information.status AS preorder_info_status,
              COALESCE( preorder_information.who_will_order_devices, responsible_bodies.who_will_order_devices ) AS who_will_order_devices

      FROM    schools   INNER JOIN responsible_bodies
                                ON responsible_bodies.id = schools.responsible_body_id
                  LEFT OUTER JOIN  preorder_information
                                ON preorder_information.school_id = schools.id
                  LEFT OUTER JOIN  school_device_allocations AS std_device_allocation
                                ON std_device_allocation.school_id = schools.id
                              AND  std_device_allocation.device_type = 'std_device'
                  LEFT OUTER JOIN  school_device_allocations AS coms_device_allocation
                                ON coms_device_allocation.school_id = schools.id
                              AND  coms_device_allocation.device_type = 'coms_device'

      WHERE  std_device_allocation.cap > 0
          OR std_device_allocation.allocation > 0
          OR coms_device_allocation.cap > 0
          OR coms_device_allocation.allocation > 0
    SQL
  end
end
