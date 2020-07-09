require 'rails_helper'

RSpec.describe ImportBTWifiVoucherAllocationsService, type: :model do
  let!(:local_authority) { create(:local_authority, name: 'Brent') }
  let!(:trust) { create(:trust, name: 'SUNSHINE TRUST') }
  let(:import_data_csv) do
    [
      'Responsible body name,Allocation',
      'Brent,10',
      'SUNSHINE TRUST,2',
    ].join("\n")
  end

  before do
    stub_request(:get, 'https://example.com/bt-voucher-allocations.csv')
      .to_return(body: import_data_csv)
  end

  context 'for a successful import' do
    before do
      ImportBTWifiVoucherAllocationsService.new('https://example.com/bt-voucher-allocations.csv').call
    end

    it 'imports all the allocations from the CSV' do
      expect(BTWifiVoucherAllocation.count).to eq(2)
    end

    it 'assigns the vouchers to the right responsible bodies' do
      expect(trust.bt_wifi_voucher_allocation.amount).to eq(2)
      expect(local_authority.bt_wifi_voucher_allocation.amount).to eq(10)
    end
  end

  context 'when the CSV has stray spaces in it' do
    before do
      ImportBTWifiVoucherAllocationsService.new('https://example.com/bt-voucher-allocations.csv').call
    end

    let(:import_data_csv) do
      [
        'Responsible body name,Allocation',
        ' Brent , 10 ',
      ].join("\n")
    end

    it 'strips the spaces out' do
      expect(local_authority.bt_wifi_voucher_allocation.amount).to eq(10)
    end
  end

  context "when the responsible body is specified but doesn't match an existing record" do
    let(:import_data_csv) do
      [
        'Responsible body name,Allocation',
        'Brent,10',
        'Non-existent LA,2',
      ].join("\n")
    end

    it 'raises an exception and rolls back previous imports' do
      expect {
        ImportBTWifiVoucherAllocationsService.new('https://example.com/bt-voucher-allocations.csv').call
      }.to raise_error(ArgumentError, "could not find responsible body with name 'Non-existent LA'")
      expect(BTWifiVoucherAllocation.count).to eq(0)
    end
  end
end
