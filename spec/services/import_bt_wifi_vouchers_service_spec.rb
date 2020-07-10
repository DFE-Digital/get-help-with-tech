require 'rails_helper'

RSpec.describe ImportBTWifiVouchersService, type: :model do
  let!(:local_authority) { create(:local_authority, name: 'Brent') }
  let!(:trust) { create(:trust, name: 'SUNSHINE TRUST') }
  let(:import_data_csv) do
    [
      'Username,Password,Assigned to responsible body name',
      'aaa,bbb,',
      'ccc,ddd,Brent',
      'eee,fff,SUNSHINE TRUST',
      'ggg,hhh,SUNSHINE TRUST',
    ].join("\n")
  end

  before do
    stub_request(:get, 'https://example.com/bt-vouchers.csv')
      .to_return(body: import_data_csv)

    ImportBTWifiVouchersService.new('https://example.com/bt-vouchers.csv').call
  end

  it 'imports all the vouchers from the CSV' do
    expect(BTWifiVoucher.count).to eq(4)
  end

  it 'assigns the vouchers to the right responsible bodies' do
    expect(trust.bt_wifi_vouchers.count).to eq(2)
    expect(local_authority.bt_wifi_vouchers.count).to eq(1)
  end

  it 'imports unassigned vouchers as unassigned' do
    expect(BTWifiVoucher.unassigned.count).to eq(1)
  end

  it 'imports usernames & passwords correctly' do
    expect(trust.bt_wifi_vouchers.order('username asc').pluck(:username)).to eq(%w[eee ggg])
    expect(trust.bt_wifi_vouchers.order('username asc').pluck(:password)).to eq(%w[fff hhh])
  end
end
