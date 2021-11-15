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
              schools.raw_laptop_allocation AS allocation,
              CASE schools.order_state
                  WHEN 'cannot_order' THEN schools.raw_laptops_ordered
                  ELSE schools.raw_laptop_allocation + schools.over_order_reclaimed_laptops + schools.circumstances_laptops
              END AS cap,
              schools.raw_laptops_ordered AS devices_ordered,
              schools.raw_router_allocation AS coms_allocation,
              CASE schools.order_state
                  WHEN 'cannot_order' THEN schools.raw_routers_ordered
                  ELSE schools.raw_router_allocation + schools.over_order_reclaimed_routers + schools.circumstances_routers
              END AS coms_cap,
              schools.raw_routers_ordered AS coms_devices_ordered,
              schools.preorder_status AS preorder_info_status,
              COALESCE( schools.who_will_order_devices, responsible_bodies.default_who_will_order_devices_for_schools ) AS who_will_order_devices

      FROM    schools   INNER JOIN responsible_bodies
                                ON responsible_bodies.id = schools.responsible_body_id

      WHERE (CASE schools.order_state
                 WHEN 'cannot_order' THEN schools.raw_laptops_ordered
                 ELSE schools.raw_laptop_allocation + schools.over_order_reclaimed_laptops + schools.circumstances_laptops
             END) > 0
          OR schools.raw_laptop_allocation > 0
          OR (CASE schools.order_state
                  WHEN 'cannot_order' THEN schools.raw_routers_ordered
                  ELSE schools.raw_router_allocation + schools.over_order_reclaimed_routers + schools.circumstances_routers
              END) > 0
          OR schools.raw_router_allocation > 0
    SQL
  end
end
