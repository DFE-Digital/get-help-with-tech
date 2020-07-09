require 'rails_helper'

RSpec.describe ImportBTWifiVouchersService, type: :model do
  it 'imports BT Wifi vouchers from an online CSV file and remembers who they were distributed to' do
    local_authority = create(:local_authority, name: 'Brent')
    trust = create(:trust, name: 'SUNSHINE TRUST')

    data = [
      'Username,Password,Assigned to responsible body name',
      'aaa,bbb,',
      'ccc,ddd,Brent',
      'eee,fff,SUNSHINE TRUST',
      'ggg,hhh,SUNSHINE TRUST',
    ].join("\n")

    stub_request(:get, 'https://example.com/bt-vouchers.csv')
      .to_return(body: data)

    ImportBTWifiVouchersService.new('https://example.com/bt-vouchers.csv').call

    expect(BTWifiVoucher.count).to eq(4)

    expect(trust.bt_wifi_vouchers.count).to eq(2)
    expect(trust.bt_wifi_vouchers.order('username asc').pluck(:username)).to eq(%w[eee ggg])
    expect(trust.bt_wifi_vouchers.order('username asc').pluck(:password)).to eq(%w[fff hhh])
    expect(local_authority.bt_wifi_vouchers.count).to eq(1)
    expect(BTWifiVoucher.unassigned.count).to eq(1)
  end
end
