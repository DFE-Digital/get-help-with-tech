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
  end

  context 'for a successful import' do
    before do
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

  context 'when the CSV has stray spaces in it' do
    before do
      ImportBTWifiVouchersService.new('https://example.com/bt-vouchers.csv').call
    end

    let(:import_data_csv) do
      [
        'Username,Password,Assigned to responsible body name',
        ' ccc , ddd ,Brent ',
      ].join("\n")
    end

    it 'strips the spaces out' do
      expect(local_authority.bt_wifi_vouchers.count).to eq(1)
      expect(local_authority.bt_wifi_vouchers.first.username).to eq('ccc')
      expect(local_authority.bt_wifi_vouchers.first.password).to eq('ddd')
    end
  end

  context "when the responsible body is specified but doesn't match an existing record" do
    let(:import_data_csv) do
      [
        'Username,Password,Assigned to responsible body name',
        'aaa,bbb,Brent',
        'ccc,ddd,Non-existent LA',
      ].join("\n")
    end

    it 'raises an exception and rolls back the imported vouchers prior to the exception' do
      expect {
        ImportBTWifiVouchersService.new('https://example.com/bt-vouchers.csv').call
      }.to raise_error(ArgumentError, "could not find responsible body with name 'Non-existent LA'")
      expect(BTWifiVoucher.count).to eq(0)
    end
  end
end
