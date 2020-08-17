require 'rails_helper'

RSpec.describe Computacenter::OutgoingAPI::CapUpdateRequest do
  let(:response_body) { 'response body' }
  let(:allocation_1) { create(:school_device_allocation) }
  let(:allocation_2) { create(:school_device_allocation) }

  before do
    allow(Computacenter::OutgoingAPI::BaseController).to receive(:render).and_return('rendered XML')
    stub_request(:post, Settings.computacenter.outgoing_api.endpoint).to_return(status: 200, body: response_body)
  end

  describe '#post!' do
    subject(:request) { described_class.new(allocation_ids: [allocation_1.id, allocation_2.id]) }

    it 'generates a new payload_id' do
      expect { request.post! }.to change(request, :payload_id)
    end

    it 'renders the cap_update_request XML builder template' do
      request.post!
      expect(Computacenter::OutgoingAPI::BaseController).to have_received(:render).with(:cap_update_request, hash_including(format: :xml))
    end

    it 'passes allocations and payload_id to the render call' do
      request.post!
      expect(Computacenter::OutgoingAPI::BaseController).to have_received(:render).with(
        anything,
        hash_including(
          assigns: {
            allocations: [allocation_1, allocation_2],
            payload_id: request.payload_id,
          },
        ),
      )
    end
  end
end
