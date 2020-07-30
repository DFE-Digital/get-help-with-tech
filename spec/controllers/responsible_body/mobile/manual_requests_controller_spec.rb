require 'rails_helper'

RSpec.describe ResponsibleBody::Mobile::ManualRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user
    end

    describe 'create' do
      let(:mno) { create(:mobile_network) }
      let(:form_attrs) { attributes_for(:extra_mobile_data_request, mobile_network_id: mno.id) }
      let(:request_data) { { extra_mobile_data_request: form_attrs, confirm: 'confirm' } }

      before do
        ActiveJob::Base.queue_adapter = :test
      end

      after do
        ActiveJob::Base.queue_adapter = :inline
      end

      it 'sends an sms to the account holder of the request' do
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).once
      end
    end
  end
end
