require 'rails_helper'

RSpec.describe School::Internet::Mobile::ManualRequestsController, type: :controller do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  context 'when authenticated' do
    before do
      sign_in_as user
    end

    describe '#create' do
      let(:mno) { create(:mobile_network) }
      let(:form_attrs) { attributes_for(:extra_mobile_data_request, mobile_network_id: mno.id) }
      let(:request_data) { { urn: school.urn, extra_mobile_data_request: form_attrs, confirm: 'confirm' } }

      context 'when school.hide_mno?' do
        let(:school) { create(:school, hide_mno: true) }
        let(:user) { create(:school_user, schools: [school]) }

        it 'returns 404' do
          post :create, params: request_data
          expect(response).to be_not_found
        end
      end

      it 'sends an SMS to the account holder of the request' do
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).once
      end
    end
  end
end
