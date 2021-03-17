class Support::ServicePerformance
  def percentage_of_devolved_schools_that_have_signed_in
    (number_of_devolved_schools_that_have_signed_in * 100.0 / number_of_devolved_schools).round
  end

  def number_of_devolved_schools_that_have_signed_in
    @number_of_devolved_schools_that_have_signed_in ||= School
      .gias_status_open
      .that_will_order_devices
      .joins(user_schools: :user)
      .where('users.sign_in_count > 0')
      .count('DISTINCT(schools.id)')
  end

  def number_of_devolved_schools
    @number_of_devolved_schools ||= School
      .gias_status_open
      .that_will_order_devices
      .count
  end

  def number_of_centrally_managed_schools
    @number_of_centrally_managed_schools ||= School
      .gias_status_open
      .that_are_centrally_managed
      .count
  end

  def total_devices_available
    # SchoolDeviceAllocation.std_device.sum(:allocation)
    1_302_110
  end

  def total_devices_ordered
    SchoolDeviceAllocation.std_device.sum(:devices_ordered)
  end

  def total_devices_remaining
    SchoolDeviceAllocation.std_device.sum('allocation - devices_ordered')
  end

  def number_of_devolved_schools_that_have_fully_ordered
    @number_of_devolved_schools_that_have_fully_ordered ||=
      School
      .gias_status_open
      .that_will_order_devices
      .joins(:device_allocations)
      .merge(SchoolDeviceAllocation.std_device.has_fully_ordered)
      .count
  end

  def number_of_devolved_schools_that_have_partially_ordered
    @number_of_devolved_schools_that_have_partially_ordered ||=
      School
      .gias_status_open
      .that_will_order_devices
      .joins(:device_allocations)
      .merge(SchoolDeviceAllocation.std_device.has_partially_ordered)
      .count
  end

  def number_of_devolved_schools_that_have_not_ordered
    @number_of_devolved_schools_that_have_not_ordered ||=
      School
      .gias_status_open
      .that_will_order_devices
      .joins(:device_allocations)
      .merge(SchoolDeviceAllocation.std_device.has_not_ordered)
      .count
  end

  def percentage_of_devolved_schools_that_have_fully_ordered
    (number_of_devolved_schools_that_have_fully_ordered * 100.0 / number_of_devolved_schools).round
  end

  def percentage_of_devolved_schools_that_have_partially_ordered
    (number_of_devolved_schools_that_have_partially_ordered * 100.0 / number_of_devolved_schools).round
  end

  def percentage_of_devolved_schools_that_have_not_ordered
    (number_of_devolved_schools_that_have_not_ordered * 100.0 / number_of_devolved_schools).round
  end

  def percentage_of_responsible_bodies_that_have_signed_in
    (number_of_responsible_bodies_that_have_signed_in * 100.0 / number_of_responsible_bodies).round
  end

  def number_of_responsible_bodies_that_have_signed_in
    @number_of_responsible_bodies_that_have_signed_in ||= User
      .where.not(responsible_body: nil)
      .signed_in_at_least_once
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies
    @number_of_responsible_bodies ||= ResponsibleBody
      .gias_status_open
      .count
  end

  def number_of_responsible_bodies_managing_centrally
    @number_of_responsible_bodies_managing_centrally ||= School
      .gias_status_open
      .that_are_centrally_managed
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_fully_ordered
    number_of_responsible_bodies_managing_centrally - number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered
  end

  def number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered
    @number_of_responsible_bodies_managing_centrally_that_have_not_fully_ordered ||= School
      .gias_status_open
      .that_are_centrally_managed
      .joins(:device_allocations)
      .merge(SchoolDeviceAllocation.std_device.has_not_fully_ordered)
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_partially_ordered
    @number_of_responsible_bodies_managing_centrally_that_have_partially_ordered ||= School
      .gias_status_open
      .that_are_centrally_managed
      .joins(:device_allocations)
      .merge(SchoolDeviceAllocation.std_device.has_partially_ordered)
      .count('DISTINCT(responsible_body_id)')
  end

  def number_of_responsible_bodies_managing_centrally_that_have_not_ordered
    number_of_responsible_bodies_managing_centrally - number_of_responsible_bodies_managing_centrally_that_have_fully_ordered - number_of_responsible_bodies_managing_centrally_that_have_partially_ordered
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_fully_ordered
    (number_of_responsible_bodies_managing_centrally_that_have_fully_ordered * 100.0 / number_of_responsible_bodies_managing_centrally).round
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_partially_ordered
    (number_of_responsible_bodies_managing_centrally_that_have_partially_ordered * 100.0 / number_of_responsible_bodies_managing_centrally).round
  end

  def percentage_of_responsible_bodies_managing_centrally_that_have_not_ordered
    (number_of_responsible_bodies_managing_centrally_that_have_not_ordered * 100.0 / number_of_responsible_bodies_managing_centrally).round
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
    needs_contact_count = preorder_information_counts_by_status['needs_contact'] || 0
    has_contact_count = preorder_information_counts_by_status['school_will_be_contacted'] || 0
    contacted_count = preorder_information_counts_by_status['school_contacted'] || 0
    school_ready_count = preorder_information_counts_by_status['school_ready'] || 0
    needs_contact_count + has_contact_count + contacted_count + school_ready_count
  end

  def number_of_schools_managed_centrally
    needs_information = preorder_information_counts_by_status['needs_info'] || 0
    ready = preorder_information_counts_by_status['ready'] || 0

    needs_information + ready
  end

  def preorder_information_counts_by_status
    PreorderInformation
      .group(:status)
      .count
  end

  def preorder_information_by_status(status)
    PreorderInformation
      .where(status: status)
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

  def total_extra_mobile_data_requests_with_problems(scope: ExtraMobileDataRequest)
    scope
      .in_a_problem_state
      .count
  end
end
