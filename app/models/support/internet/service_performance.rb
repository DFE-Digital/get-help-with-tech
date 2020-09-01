class Support::Internet::ServicePerformance
  def total_signed_in_users
    responsible_body_users_signed_in_at_least_once + mno_users_signed_in_at_least_once
  end

  def responsible_body_users_signed_in_at_least_once
    User
      .from_responsible_body_in_connectivity_pilot
      .signed_in_at_least_once
      .count
  end

  def mno_users_signed_in_at_least_once
    User
      .mno_users
      .signed_in_at_least_once
      .count
  end

  def number_of_different_responsible_bodies_signed_in
    User
      .from_responsible_body_in_connectivity_pilot
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

  def number_of_distributed_bt_wifi_vouchers
    BTWifiVoucher.distributed.count
  end

  def number_of_responsible_bodies_with_distributed_bt_wifi_vouchers
    BTWifiVoucher
      .distributed
      .distinct
      .pluck(:responsible_body_id)
      .size
  end

  def total_extra_mobile_data_requests
    ExtraMobileDataRequest.count
  end

  def extra_mobile_data_requests_by_status
    ExtraMobileDataRequest.group(:status).count
  end

  def extra_mobile_data_requests_by_mobile_network_brand
    ExtraMobileDataRequest
      .joins(:mobile_network)
      .group('mobile_networks.brand')
      .count
      .sort_by { |_k, v| v }
      .reverse
  end
end
