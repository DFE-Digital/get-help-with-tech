require 'rails_helper'

RSpec.describe BTWifiVoucher, type: :model do
  describe '#to_csv' do
    let(:trust) { create(:trust) }
    let!(:unassigned_bt_wifi_voucher) { create(:bt_wifi_voucher) }
    let!(:assigned_bt_wifi_vouchers) { create_list(:bt_wifi_voucher, 2, responsible_body: trust) }

    it 'generates a CSV string' do
      csv_string = trust.bt_wifi_vouchers.to_csv

      expect(csv_string.split("\n").size).to eq(3)
      expect(csv_string).to include('Username,Password')
      expect(csv_string).to include("#{assigned_bt_wifi_vouchers[0].username},#{assigned_bt_wifi_vouchers[0].password}")
      expect(csv_string).to include("#{assigned_bt_wifi_vouchers[1].username},#{assigned_bt_wifi_vouchers[1].password}")

      expect(csv_string).not_to include("#{unassigned_bt_wifi_voucher.username},#{unassigned_bt_wifi_voucher.password}")
    end
  end
end
