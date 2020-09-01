class Support::Devices::ServicePerformance
  def responsible_body_users_signed_in_at_least_once
    User
      .from_responsible_body_in_devices_pilot
      .signed_in_at_least_once
      .count
  end

  def number_of_different_responsible_bodies_signed_in
    User
      .from_responsible_body_in_devices_pilot
      .signed_in_at_least_once
      .distinct
      .pluck(:responsible_body_id)
      .size
  end

  def number_of_different_responsible_bodies_who_have_chosen_who_will_order
    ResponsibleBody
      .in_devices_pilot
      .chosen_who_will_order
      .count
  end

  def number_of_different_responsible_bodies_with_at_least_one_preorder_information_completed
    ResponsibleBody
      .in_devices_pilot
      .with_at_least_one_preorder_information_completed
      .count
  end

  def preorder_information_counts_by_status
    PreorderInformation
      .for_responsible_bodies_in_devices_pilot
      .group(:status)
      .count
  end

  def preorder_information_by_status(status)
    PreorderInformation
      .where(status: status)
      .count
  end
end
