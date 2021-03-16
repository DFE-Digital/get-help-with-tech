class Support::ServicePerformance
  def devolved_school_users_that_have_signed_in_at_least_once
    User
      .where(responsible_body: nil)
      .signed_in_at_least_once
      .joins(:schools)
      .merge(School.that_will_order_devices)
      .distinct
      .count
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
