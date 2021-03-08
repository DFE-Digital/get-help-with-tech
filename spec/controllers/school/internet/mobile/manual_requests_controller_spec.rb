require 'rails_helper'

RSpec.describe School::Internet::Mobile::ManualRequestsController, type: :controller do
  let(:user) { create(:school_user) }
  let(:school) { user.school }
  let(:mno) { create(:mobile_network) }
  let(:form_attrs) { attributes_for(:extra_mobile_data_request, mobile_network_id: mno.id) }
  let(:request_data) { { urn: school.urn, extra_mobile_data_request: form_attrs, confirm: 'confirm' } }

  describe '#create' do
    context 'when authenticated' do
      before do
        sign_in_as user
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
        impersonate user
      end

      it 'returns forbidden' do
        post :create, params: request_data
        expect(response).to be_forbidden
      end
    end
  end
end
