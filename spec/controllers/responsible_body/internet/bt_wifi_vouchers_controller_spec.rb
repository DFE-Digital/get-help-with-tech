require 'rails_helper'

RSpec.describe ResponsibleBody::Internet::BTWifiVouchersController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user

      @vouchers = create_list(:bt_wifi_voucher, 2, responsible_body: local_authority_user.responsible_body)
    end

    describe 'index' do
      it 'returns a CSV of the username and password' do
        get :index, format: :csv
        expect(response.media_type).to eq('text/csv')
        expect(response.body).to include('Username,Password')
        expect(response.body).to include("#{@vouchers[0].username},#{@vouchers[0].password}")
        expect(response.body).to include("#{@vouchers[1].username},#{@vouchers[1].password}")
      end

      it 'sets the `distributed_at` for vouchers that have not been distributed yet' do
        timestamp = Date.new(2020, 6, 1)
        @vouchers[0].update!(distributed_at: timestamp)
        expect(@vouchers[1].distributed_at).to be_nil

        some_time_later = Date.new(2020, 6, 5)
        Timecop.freeze(some_time_later) do
          get :index, format: :csv
        end

        expect(@vouchers[0].reload.distributed_at).to eq(timestamp)
        expect(@vouchers[1].reload.distributed_at).to eq(some_time_later)
      end
    end
  end
end
