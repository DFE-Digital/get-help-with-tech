require 'rails_helper'

RSpec.describe NotifyComputacenterOfCapUpdateJob do
  describe '#perform' do
    let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest) }
    let(:given_args) { [1, 2, 3] }

    before do
      allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
      allow(mock_request).to receive(:post!)
    end

    it 'creates a new Computacenter::OutgoingAPI::CapUpdateRequest with the given allocation_ids' do
      NotifyComputacenterOfCapUpdateJob.new.perform(given_args)
      expect(Computacenter::OutgoingAPI::CapUpdateRequest).to have_received(:new).with(allocation_ids: [1, 2, 3])
    end

    it 'posts the request' do
      NotifyComputacenterOfCapUpdateJob.new.perform(given_args)
      expect(mock_request).to have_received(:post!)
    end
  end
end
