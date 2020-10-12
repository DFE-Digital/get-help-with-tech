require 'rails_helper'

RSpec.describe Computacenter::OutgoingAPI::CapUpdateRequest do
  let(:response_body) { 'response body' }
  let(:school_1) { create(:school, computacenter_reference: '01234567') }
  let(:school_2) { create(:school, computacenter_reference: '98765432') }
  let(:allocation_1) { create(:school_device_allocation, school: school_1, device_type: 'std_device', allocation: 11, cap: 1) }
  let(:allocation_2) { create(:school_device_allocation, school: school_2, device_type: 'coms_device', allocation: 22, cap: 0) }

  before do
    @network_call = allow_computacenter_outgoing_api_calls(response_body: response_body)
  end

  describe '#post!' do
    subject(:request) { described_class.new(allocation_ids: [allocation_1.id, allocation_2.id]) }

    it 'generates a new payload_id' do
      expect { request.post! }.to change(request, :payload_id)
    end

    it 'POSTs the body to the endpoint using Basic Auth' do
      request.post!

      expect(@network_call.with(basic_auth: %w[user pass])).to have_been_requested
    end

    it 'generates a correct body' do
      request.payload_id = '123456789'
      request.timestamp = Time.new(2020, 9, 2, 15, 3, 35, '+02:00')
      request.post!

      expected_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <CapAdjustmentRequest payloadID="123456789" dateTime="2020-09-02T15:03:35+02:00">
          <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="01234567" capAmount="1"/>
          <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="98765432" capAmount="0"/>
        </CapAdjustmentRequest>
      XML
      expect(@network_call.with(body: expected_xml)).to have_been_requested
    end

    context 'when the response status is success' do
      it 'returns an HTTP::Response object' do
        expect(request.post!).to be_a(HTTP::Response)
      end
    end

    context 'when the response status is not a success' do
      before do
        WebMock.reset!
        allow_computacenter_outgoing_api_calls(response_body: response_body, response_status: 401)
      end

      it 'raises an error' do
        expect { request.post! }.to raise_error(Computacenter::OutgoingAPI::Error)
      end

      it 'does not change the timestamp and payload_id on the allocations' do
        expect { request.post! }.to raise_error(Computacenter::OutgoingAPI::Error)
        allocation_1.reload
        allocation_2.reload
        expect(allocation_1.cap_update_request_timestamp).to be_nil
        expect(allocation_1.cap_update_request_payload_id).to be_nil
        expect(allocation_2.cap_update_request_timestamp).to be_nil
        expect(allocation_2.cap_update_request_payload_id).to be_nil
      end
    end

    context 'when the response contains an error' do
      let(:response_body) do
        '<CapAdjustmentResponse dateTime="2020-08-21T12:30:40Z" payloadID="11111111-1111-1111-1111-111111111111"><HeaderResult errorDetails="Non of the records are processed" piMessageID="11111111111111111111111111111111" status="Failed"/><FailedRecords><Record capAmount="9" capType="DfE_RemainThresholdQty|Std_Device" errorDetails="New cap must be greater than or equal to used quantity" shipTO="11111111" status="Failed"/></FailedRecords></CapAdjustmentResponse>'
      end

      it 'raises an error' do
        expect { request.post! }.to raise_error(Computacenter::OutgoingAPI::Error)
      end
    end

    context 'when the response does not contain an error' do
      let(:response_body) do
        '<CapAdjustmentResponse dateTime="2020-09-14T21:55:37Z" payloadID="11111111-1111-1111-1111-111111111111"><HeaderResult piMessageID="11111111111111111111111111111111" status="Success"/><FailedRecords/></CapAdjustmentResponse>'
      end

      it 'does not raise an error' do
        expect { request.post! }.not_to raise_error
      end
    end
  end
end
