class AssignBTWifiVouchersToResponsibleBodiesService
  def call
    all_allocations = BTWifiVoucherAllocation.includes(responsible_body: [:bt_wifi_vouchers])

    all_allocations.each do |allocation|
      number_of_vouchers_already_assigned = allocation.responsible_body.bt_wifi_vouchers.size
      number_to_assign = allocation.amount - number_of_vouchers_already_assigned
      BTWifiVoucher.assign(number_to_assign, to: allocation.responsible_body) if number_to_assign > 0
    end
  end
end
