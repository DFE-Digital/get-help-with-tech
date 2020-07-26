class ServicePerformance
  def total_signed_in_users
    User
      .responsible_body_users
      .or(User.mno_users)
      .signed_in_at_least_once
      .count
  end

  def number_of_different_responsible_bodies_signed_in
    User
      .responsible_body_users
      .signed_in_at_least_once
      .distinct
      .pluck(:responsible_body_id)
      .size
  end

  def number_of_different_mnos_signed_in
    User
      .mno_users
      .signed_in_at_least_once
      .distinct
      .pluck(:mobile_network_id)
      .size
  end
end
