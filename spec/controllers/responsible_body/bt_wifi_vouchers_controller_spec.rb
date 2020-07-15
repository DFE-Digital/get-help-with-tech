require 'rails_helper'

RSpec.describe ResponsibleBody::BTWifiVouchersController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user
    end

    describe 'index' do
      it 'returns a CSV of the username and password' do
        vouchers = create_list(:bt_wifi_voucher, 2, responsible_body: local_authority_user.responsible_body)

        get :index, format: :csv
        expect(response.media_type).to eq('text/csv')
        expect(response.body).to include('Username,Password')
        expect(response.body).to include("#{vouchers[0].username},#{vouchers[0].password}")
        expect(response.body).to include("#{vouchers[1].username},#{vouchers[1].password}")
      end
    end
  end
end
