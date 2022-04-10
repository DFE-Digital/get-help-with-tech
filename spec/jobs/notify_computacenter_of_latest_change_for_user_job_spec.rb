require 'rails_helper'

RSpec.describe NotifyComputacenterOfLatestChangeForUserJob do
  describe '#perform' do
    let(:school) { create(:school, :manages_orders) }
    let(:user) { create(:school_user, :relevant_to_computacenter, school:) }
    let(:request_succeeded) { true }
    let(:mock_request) do
      instance_double(
        Computacenter::ServiceNowUserImportAPI::ImportUserChangeRequest,
        cc_transaction_id: '123456',
        timestamp: Time.zone.now.utc,
        success?: request_succeeded,
      )
    end
    let(:job) { described_class.new }
    let(:user_change) { Computacenter::UserChange.latest_for_user(user) }
    let(:mock_response) { instance_double(HTTP::Response) }

    before do
      allow(Computacenter::ServiceNowUserImportAPI::ImportUserChangeRequest).to receive(:new).and_return(mock_request)
      allow(mock_request).to receive(:post!).and_return(mock_response)
    end

    it 'creates a new Computacenter::ServiceNowUserImportAPI::ImportUserChangeRequest with the latest user change for the given user_id' do
      job.perform(user.id)
      expect(Computacenter::ServiceNowUserImportAPI::ImportUserChangeRequest).to have_received(:new).with(user_change:)
    end

    it 'posts the request' do
      job.perform(user.id)
      expect(mock_request).to have_received(:post!)
    end

    context 'when the request succeeds' do
      it 'updates the timestamp and transaction_id on the UserChange' do
        job.perform(user.id)
        user_change.reload
        expect(user_change.cc_import_api_timestamp).not_to be_nil
        expect(user_change.cc_import_api_transaction_id).to eq('123456')
      end

      it 'returns the response' do
        expect(job.perform(user.id)).to eq(mock_response)
      end
    end

    context 'when the request does not succeed' do
      before do
        allow(mock_request).to receive(:post!).and_raise(Computacenter::ServiceNowUserImportAPI::Error)
      end

      it 'raises an error' do
        expect { job.perform(user.id) }.to raise_error(Computacenter::ServiceNowUserImportAPI::Error)
      end

      it 'does not update the timestamp and transaction_id on the UserChange' do
        -> { job.perform(user.id) }
        user_change.reload
        expect(user_change.cc_import_api_timestamp).to be_nil
        expect(user_change.cc_import_api_transaction_id).to be_nil
      end
    end
  end
end
