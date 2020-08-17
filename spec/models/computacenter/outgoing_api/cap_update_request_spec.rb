require 'rails_helper'

RSpec.describe Computacenter::OutgoingAPI::CapUpdateRequest do
  let(:response_body) { 'response body' }
  let(:allocation_1) { create(:school_device_allocation) }
  let(:allocation_2) { create(:school_device_allocation) }
  let(:mock_status) { double(HTTP::Response::Status, code: 200, success?: true) }
  let(:mock_response) { double(HTTP::Response, status: mock_status, body: response_body) }

  before do
    allow(Computacenter::OutgoingAPI::BaseController).to receive(:render).and_return('rendered XML')
    stub_request(:post, Settings.computacenter.outgoing_api.endpoint).to_return(status: 200, body: response_body)
  end

  describe '#post!' do
    subject(:request) { described_class.new(allocation_ids: [allocation_1.id, allocation_2.id]) }
    let(:mock_http) { double(HTTP) }

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

    it 'POSTs the body to the endpoint using Basic Auth' do
      allow(Computacenter::OutgoingAPI::BaseController).to receive(:render).and_return('mock body')
      expect(HTTP).to receive(:basic_auth).with(user: request.username, pass: request.password).and_return(mock_http)
      expect(mock_http).to receive(:post).with(request.endpoint, body: 'mock body').and_return(mock_response)
      request.post!
    end

    context 'when the response status is success' do
      let(:mock_status) { double(HTTP::Response::Status, code: 200, success?: true) }

      it 'returns the response ' do
        expect(request.post!).to be_a(HTTP::Response)
      end
    end

    context 'when the response status is not a success' do
      let(:mock_status) { double(HTTP::Response::Status, code: 401, success?: false) }

      before do
        allow(HTTP).to receive(:basic_auth).and_return(mock_http)
        allow(mock_http).to receive(:post).and_return(mock_response)
      end

      it 'raises an error' do
        expect { request.post! }.to raise_error(Computacenter::OutgoingAPI::Error)
      end
    end
  end


end
