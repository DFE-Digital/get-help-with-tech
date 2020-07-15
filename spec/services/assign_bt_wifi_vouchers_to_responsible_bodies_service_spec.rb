require 'rails_helper'

RSpec.describe AssignBTWifiVouchersToResponsibleBodiesService, type: :model do
  let(:local_authority) { create(:local_authority, name: 'Brent') }
  let(:another_local_authority) { create(:local_authority, name: 'Wandsworth') }

  before do
    create_list(:bt_wifi_voucher, 5, :unassigned)
  end

  it 'assigns vouchers to responsible bodies that have fewer vouchers than allocations' do
    create(:bt_wifi_voucher_allocation, amount: 2, responsible_body: local_authority)

    create(:bt_wifi_voucher_allocation, amount: 2, responsible_body: another_local_authority)
    create(:bt_wifi_voucher, responsible_body: another_local_authority)

    AssignBTWifiVouchersToResponsibleBodiesService.new.call

    expect(local_authority.bt_wifi_vouchers.count).to eq(2)
    expect(another_local_authority.bt_wifi_vouchers.count).to eq(2)
    expect(BTWifiVoucher.unassigned.count).to eq(2)
  end

  it 'does not touch responsible bodies that have their allocated vouchers' do
    create_list(:bt_wifi_voucher, 5, responsible_body: local_authority)
    create(:bt_wifi_voucher_allocation, amount: 5, responsible_body: local_authority)

    AssignBTWifiVouchersToResponsibleBodiesService.new.call

    expect(local_authority.bt_wifi_vouchers.count).to eq(5)
    expect(BTWifiVoucher.unassigned.count).to eq(5)
  end
end
