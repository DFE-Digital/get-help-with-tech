class Support::Internet::ServicePerformance
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
