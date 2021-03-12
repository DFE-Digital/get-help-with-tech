require 'rails_helper'

RSpec.describe ResponsibleBody::Internet::Mobile::ManualRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  describe '#create' do
    let(:mno) { create(:mobile_network) }
    let(:form_attrs) { attributes_for(:extra_mobile_data_request, mobile_network_id: mno.id) }
    let(:request_data) { { extra_mobile_data_request: form_attrs, confirm: 'confirm' } }

    context 'when authenticated' do
      before do
        sign_in_as local_authority_user
      end

      it 'sends an SMS to the account holder of the request' do
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).once
      end
    end

    context 'when support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate local_authority_user
      end

      it 'returns forbidden' do
        post :create, params: request_data
        expect(response).to be_forbidden
      end
    end
  end
end
