class Support::ServicePerformance
  def percentage_of_devolved_schools_that_have_signed_in
    if number_of_devolved_schools.positive?
      (number_of_devolved_schools_that_have_signed_in * 100.0 / number_of_devolved_schools).round
    else
      0
    end
  end

  def number_of_devolved_schools_that_have_signed_in
    @number_of_devolved_schools_that_have_signed_in ||=
      School
      .gias_status_open
      .school_will_order_devices
      .joins(user_schools: :user)
      .where('users.sign_in_count > 0')
      .count('DISTINCT(schools.id)')
  end

  def number_of_devolved_schools
    @number_of_devolved_schools ||=
      School
      .gias_status_open
      .school_will_order_devices
      .count
  end

  def number_of_centrally_managed_schools
    @number_of_centrally_managed_schools ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .count
  end

  def total_devices_available
    sum_allocation(Arel.sql("CASE order_state WHEN 'cannot_order' THEN raw_laptops_ordered ELSE raw_laptop_cap END"))
  end

  def total_devices_ordered
    sum_allocation('raw_laptops_ordered')
  end

  def total_devices_remaining
    sum_allocation(Arel.sql("CASE order_state WHEN 'cannot_order' THEN 0 ELSE raw_laptop_cap - raw_laptops_ordered END"))
  end

  def total_routers_available
    sum_allocation(Arel.sql("CASE order_state WHEN 'cannot_order' THEN raw_routers_ordered ELSE raw_router_cap END"))
  end

  def total_routers_ordered
    sum_allocation('raw_routers_ordered')
  end

  def total_routers_remaining
    sum_allocation(Arel.sql("CASE order_state WHEN 'cannot_order' THEN 0 ELSE raw_router_cap - raw_routers_ordered END"))
  end

  def sum_allocation(sum_expression)
    devolved = School.gias_status_open.school_will_order_devices.sum(sum_expression)
    managed = School.responsible_body_will_order_devices.sum(sum_expression)
    devolved + managed
  end

  def segmented_device_counts
    device_type = :laptop

    [
      Support::ServicePerformance::DeviceCounts.new(
        key: :open_and_devolved_schools,
        school_scope: School.gias_status_open,
        device_type: device_type,
        who_will_order_devices: 'school',
      ),
      Support::ServicePerformance::DeviceCounts.new(
        key: :closed_and_devolved_schools,
        school_scope: School.gias_status_closed,
        device_type: device_type,
        who_will_order_devices: 'school',
      ),
      Support::ServicePerformance::DeviceCounts.new(
        key: :open_and_centrally_managed_schools,
        school_scope: School.gias_status_open,
        device_type: device_type,
        who_will_order_devices: 'responsible_body',
      ),
      Support::ServicePerformance::DeviceCounts.new(
        key: :closed_and_centrally_managed_schools,
        school_scope: School.gias_status_closed,
        device_type: device_type,
        who_will_order_devices: 'responsible_body',
      ),
    ]
  end

  #
  # devolved schools - devices
  #
  def number_of_devolved_schools_that_have_fully_ordered
    @number_of_devolved_schools_that_have_fully_ordered ||=
      number_of_devolved_schools_that_have(scope: School.has_fully_ordered_laptops)
  end

  def number_of_devolved_schools_that_have_partially_ordered
    @number_of_devolved_schools_that_have_partially_ordered ||=
      number_of_devolved_schools_that_have(scope: School.has_partially_ordered_laptops)
  end

  def number_of_devolved_schools_that_have_not_ordered
    @number_of_devolved_schools_that_have_not_ordered ||=
      number_of_devolved_schools_that_have(scope: School.has_not_ordered_laptops)
  end

  def percentage_of_devolved_schools_that_have_fully_ordered
    if number_of_devolved_schools.positive?
      (number_of_devolved_schools_that_have_fully_ordered * 100.0 / number_of_devolved_schools).round
    else
      0
    end
  end

  def percentage_of_devolved_schools_that_have_partially_ordered
    if number_of_devolved_schools.positive?
      (number_of_devolved_schools_that_have_partially_ordered * 100.0 / number_of_devolved_schools).round
    else
      0
    end
  end

  def percentage_of_devolved_schools_that_have_not_ordered
    if number_of_devolved_schools.positive?
      (number_of_devolved_schools_that_have_not_ordered * 100.0 / number_of_devolved_schools).round
    else
      0
    end
  end

  #
  # devolved schools - routers
  #
  def number_of_devolved_schools_that_have_fully_ordered_routers
    @number_of_devolved_schools_that_have_fully_ordered_routers ||=
      number_of_devolved_schools_that_have(scope: School.has_fully_ordered_routers)
  end

  def number_of_devolved_schools_that_have_partially_ordered_routers
    @number_of_devolved_schools_that_have_partially_ordered_routers ||=
      number_of_devolved_schools_that_have(scope: School.has_partially_ordered_routers)
  end

  def number_of_devolved_schools_that_have_not_ordered_routers
    @number_of_devolved_schools_that_have_not_ordered_routers ||=
      number_of_devolved_schools_that_have(scope: School.where("raw_routers_ordered = 0 and (CASE order_state WHEN 'cannot_order' THEN raw_routers_ordered ELSE raw_router_cap END) > 0"))
  end

  def number_of_devolved_schools_that_have_a_router_allocation
    @number_of_devolved_schools_that_have_a_router_allocation ||=
      number_of_devolved_schools_that_have(scope: School.where("(CASE order_state WHEN 'cannot_order' THEN raw_routers_ordered ELSE raw_router_cap END) > 0"))
  end

  def percentage_of_devolved_schools_that_have_fully_ordered_routers
    if number_of_devolved_schools_that_have_a_router_allocation.positive?
      (number_of_devolved_schools_that_have_fully_ordered_routers * 100.0 / number_of_devolved_schools_that_have_a_router_allocation).round
    else
      0
    end
  end

  def percentage_of_devolved_schools_that_have_partially_ordered_routers
    if number_of_devolved_schools_that_have_a_router_allocation.positive?
      (number_of_devolved_schools_that_have_partially_ordered_routers * 100.0 / number_of_devolved_schools_that_have_a_router_allocation).round
    else
      0
    end
  end

  def percentage_of_devolved_schools_that_have_not_ordered_routers
    if number_of_devolved_schools_that_have_a_router_allocation.positive?
      (number_of_devolved_schools_that_have_not_ordered_routers * 100.0 / number_of_devolved_schools_that_have_a_router_allocation).round
    else
      0
    end
  end

  def number_of_devolved_schools_that_have(scope:)
    School
    .gias_status_open
    .school_will_order_devices
    .merge(scope)
    .count
  end

  #
  # responsible bodies
  #
  def percentage_of_responsible_bodies_that_have_signed_in
    (number_of_responsible_bodies_that_have_signed_in * 100.0 / number_of_responsible_bodies).round
  end

  def number_of_responsible_bodies_that_have_signed_in
    @number_of_responsible_bodies_that_have_signed_in ||=
      User
      .where.not(responsible_body: nil)
      .signed_in_at_least_once
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies
    @number_of_responsible_bodies ||=
      ResponsibleBody
      .gias_status_open
      .count
  end

  def number_of_responsible_bodies_managing_centrally
    @number_of_responsible_bodies_managing_centrally ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .count('DISTINCT(responsible_body_id)')
  end

  #
  # responsible bodies - centrally managed devices
  #
  def number_of_responsible_bodies_managing_centrally_that_have_fully_ordered
    number_of_responsible_bodies_managing_centrally - number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered
  end

  def number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered
    @number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .has_not_fully_ordered_laptops
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_partially_ordered
    @number_of_responsible_bodies_managing_centrally_that_have_partially_ordered ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .has_partially_ordered_laptops
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_not_ordered
    number_of_responsible_bodies_managing_centrally - number_of_responsible_bodies_managing_centrally_that_have_fully_ordered - number_of_responsible_bodies_managing_centrally_that_have_partially_ordered
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_fully_ordered
    if number_of_responsible_bodies_managing_centrally.positive?
      (number_of_responsible_bodies_managing_centrally_that_have_fully_ordered * 100.0 / number_of_responsible_bodies_managing_centrally).round
    else
      0
    end
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_partially_ordered
    if number_of_responsible_bodies_managing_centrally.positive?
      (number_of_responsible_bodies_managing_centrally_that_have_partially_ordered * 100.0 / number_of_responsible_bodies_managing_centrally).round
    else
      0
    end
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_not_ordered
    if number_of_responsible_bodies_managing_centrally.positive?
      (number_of_responsible_bodies_managing_centrally_that_have_not_ordered * 100.0 / number_of_responsible_bodies_managing_centrally).round
    else
      0
    end
  end

  #
  # responsible bodies - centrally managed routers
  #
  def number_of_responsible_bodies_managing_centrally_that_have_fully_ordered_routers
    number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation - number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered_routers
  end

  def number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered_routers
    @number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered_routers ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .has_not_fully_ordered_routers
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_partially_ordered_routers
    @number_of_responsible_bodies_managing_centrally_that_have_partially_ordered_routers ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .has_partially_ordered_routers
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_not_ordered_routers
    @number_of_responsible_bodies_managing_centrally_that_have_not_ordered_routers ||=
      number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation - number_of_responsible_bodies_managing_centrally_that_have_fully_ordered_routers - number_of_responsible_bodies_managing_centrally_that_have_partially_ordered_routers
  end

  def number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation
    @number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation ||=
      School
      .gias_status_open
      .responsible_body_will_order_devices
      .where("(CASE order_state WHEN 'cannot_order' THEN raw_routers_ordered ELSE raw_router_cap END) > 0")
      .count('DISTINCT(responsible_body_id)')
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_fully_ordered_routers
    if number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation.positive?
      (number_of_responsible_bodies_managing_centrally_that_have_fully_ordered_routers * 100.0 / number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation).round
    else
      0
    end
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_partially_ordered_routers
    if number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation.positive?
      (number_of_responsible_bodies_managing_centrally_that_have_partially_ordered_routers * 100.0 / number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation).round
    else
      0
    end
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_not_ordered_routers
    if number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation.positive?
      (number_of_responsible_bodies_managing_centrally_that_have_not_ordered_routers * 100.0 / number_of_responsible_bodies_managing_centrally_that_have_schools_with_a_router_allocation).round
    else
      0
    end
  end

  #
  # unclaimed devices
  #
  def unclaimed_devices_by_day
    [RemainingDevicesCalculator.new.current_unclaimed_totals] + RemainingDeviceCount.order(date_of_count: :desc).first(6)
  end

  def responsible_body_users_signed_in_at_least_once
    User
      .where.not(responsible_body: nil)
      .signed_in_at_least_once
      .count
  end

  def number_of_different_responsible_bodies_signed_in
    User
      .where.not(responsible_body: nil)
      .signed_in_at_least_once
      .distinct
      .pluck(:responsible_body_id)
      .size
  end

  def number_of_different_responsible_bodies_who_have_chosen_who_will_order
    ResponsibleBody
      .chosen_who_will_order
      .count
  end

  def number_of_different_responsible_bodies_with_at_least_one_preorder_information_completed
    ResponsibleBody
      .with_at_least_one_preorder_information_completed
      .count
  end

  def number_of_schools_with_a_decision_made
    number_of_schools_devolved_to + number_of_schools_managed_centrally
  end

  def number_of_schools_devolved_to
    needs_contact_count = school_counts_by_status['needs_contact'] || 0
    has_contact_count = school_counts_by_status['school_will_be_contacted'] || 0
    contacted_count = school_counts_by_status['school_contacted'] || 0
    school_ready_count = school_counts_by_status['school_ready'] || 0
    needs_contact_count + has_contact_count + contacted_count + school_ready_count
  end

  def number_of_schools_managed_centrally
    needs_information = school_counts_by_status['needs_info'] || 0
    ready = school_counts_by_status['ready'] || 0

    needs_information + ready
  end

  def school_by_status(status)
    School
      .where(preorder_status: status)
      .count
  end

  def school_counts_by_status
    School
      .group(:preorder_status)
      .count
  end

  def total_extra_mobile_data_requests(scope: ExtraMobileDataRequest)
    scope.count
  end

  def extra_mobile_data_requests_by_status(scope: ExtraMobileDataRequest)
    scope.group(:status).count
  end

  def extra_mobile_data_requests_by_mobile_network_brand(scope: ExtraMobileDataRequest)
    scope
      .joins(:mobile_network)
      .group('mobile_networks.brand')
      .count
      .sort_by { |_k, v| v }
      .reverse
  end

  def extra_mobile_data_request_completions(from: nil, to: nil)
    scope = ReportableEvent.where(event_name: 'completion', record_type: 'ExtraMobileDataRequest')
    scope = scope.where('event_time >= ?', from.utc) if from.present?
    scope = scope.where('event_time <= ?', to.utc) if to.present?
    scope.count
  end

  def number_of_devolved_schools_that_have_made_extra_mobile_data_requests
    ExtraMobileDataRequest.from_schools.count('DISTINCT(school_id)')
  end

  def number_of_responsible_bodies_that_have_made_extra_mobile_data_requests
    ExtraMobileDataRequest.from_responsible_bodies.count('DISTINCT(responsible_body_id)')
  end

  def extra_mobile_data_requests_by_mobile_network_brand_and_status(scope: ExtraMobileDataRequest)
    data = scope
      .joins(:mobile_network)
      .group('mobile_networks.brand', "CASE when status like 'problem_%' or status = 'cancelled' or status = 'unavailable' then 'problem' else status end")
      .count

    # put statuses and counts under the brand
    result = data.each_with_object({}) do |(k, v), h|
      h[k[0]] = {} if h[k[0]].nil?
      h[k[0]][k[1]] = v
    end
    # calculate the totals
    result.each { |_k, v| v['total'] = v.values.sum }
    result.sort_by { |_k, v| v['total'] }.reverse
  end

  def total_extra_mobile_data_requests_with_problems(scope: ExtraMobileDataRequest)
    scope
      .in_a_problem_state
      .count
  end
end
