require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::WhoWillOrderController do
  let(:support_user) { create(:support_user) }
  let(:rb_user) { create(:trust_user) }

  describe '#update' do
    context 'when support user impersonating' do
      before do
        sign_in_as support_user
        impersonate rb_user
      end

      it 'returns forbidden' do
        put :update, params: { responsible_body_devices_who_will_order_form: { who_will_order: 'school' } }
        expect(response).to be_forbidden
      end
    end
  end
end
