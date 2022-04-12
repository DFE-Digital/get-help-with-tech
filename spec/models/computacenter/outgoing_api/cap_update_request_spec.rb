require 'rails_helper'

RSpec.describe Computacenter::OutgoingAPI::CapUpdateRequest do
  let(:laptops_ordered) { 0 }
  let(:routers_ordered) { 0 }
  let(:response_body) { 'response body' }
  let(:response_status) { 200 }
  let(:trust) { create(:trust, :manages_centrally) }

  let!(:school_1) do
    create(:school,
           :in_lockdown,
           :centrally_managed,
           computacenter_reference: '01234567',
           responsible_body: trust,
           laptops: [11, 11, laptops_ordered])
  end

  let!(:school_2) do
    create(:school,
           :in_lockdown,
           :centrally_managed,
           computacenter_reference: '98765432',
           responsible_body: trust,
           routers: [22, 22, routers_ordered])
  end

  let(:cap_data) do
    [
      OpenStruct.new(cap_type: Computacenter::CapTypeConverter.to_computacenter_type(:laptop),
                     ship_to: school_1.computacenter_reference,
                     cap: school_1.computacenter_cap(:laptop)),
      OpenStruct.new(cap_type: Computacenter::CapTypeConverter.to_computacenter_type(:router),
                     ship_to: school_2.computacenter_reference,
                     cap: school_2.computacenter_cap(:router)),
    ]
  end

  let!(:network_call) do
    stub_computacenter_outgoing_api_calls(response_body:, response_status:)
  end

  subject(:request) { described_class.new(cap_data:) }

  describe '#post' do
    it 'generates a new payload_id' do
      expect { request.post }.to change(request, :payload_id)
    end

    it 'POSTs the body to the endpoint using Basic Auth' do
      request.post

      expect(network_call.with(basic_auth: %w[user pass])).to have_been_requested
    end

    it 'generates a correct body' do
      request.payload_id = '123456789'
      request.timestamp = Time.new(2020, 9, 2, 15, 3, 35, '+02:00')
      request.post

      expected_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <CapAdjustmentRequest payloadID="123456789" dateTime="2020-09-02T15:03:35+02:00">
          <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="01234567" capAmount="11"/>
          <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="98765432" capAmount="22"/>
        </CapAdjustmentRequest>
      XML
      expect(network_call.with(body: expected_xml)).to have_been_requested
    end

    it 'returns the self request object' do
      expect(request.post).to eq(request)
    end

    context 'when the responsible_body is managing multiple chromebook domains' do
      subject(:request) { described_class.new(cap_data:) }

      let(:laptops_ordered) { 2 }
      let(:routers_ordered) { 3 }

      before do
        trust.update!(vcap: true)
        trust.calculate_vcaps!
        school_1.can_order!
        school_2.can_order!
        school_1.update!(will_need_chromebooks: 'yes',
                         school_or_rb_domain: 'school_1.com',
                         recovery_email_address: 'school_1@gmail.com')
        SchoolSetWhoManagesOrdersService.new(school_2, :school, notify: false).call
        school_2.update!(will_need_chromebooks: 'no')
      end

      it 'generates a correct body using devices_ordered for the cap amounts to force manual handling at TechSource' do
        request.payload_id = '123456789'
        request.timestamp = Time.new(2020, 9, 2, 15, 3, 35, '+02:00')
        request.post

        expected_xml = <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <CapAdjustmentRequest payloadID="123456789" dateTime="2020-09-02T15:03:35+02:00">
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="01234567" capAmount="11"/>
            <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="98765432" capAmount="22"/>
          </CapAdjustmentRequest>
        XML
        expect(network_call.with(body: expected_xml)).to have_been_requested
      end
    end
  end

  describe '#success?' do
    context 'when the response status is not a success' do
      let(:response_status) { 401 }

      it 'return false' do
        expect(request.post).not_to be_success
      end
    end

    context 'when the response body contains an error' do
      let(:response_status) { 200 }
      let(:response_body) do
        '<CapAdjustmentResponse dateTime="2020-08-21T12:30:40Z" payloadID="11111111-1111-1111-1111-111111111111"><HeaderResult errorDetails="Non of the records are processed" piMessageID="11111111111111111111111111111111" status="Failed"/><FailedRecords><Record capAmount="9" capType="DfE_RemainThresholdQty|Std_Device" errorDetails="New cap must be greater than or equal to used quantity" shipTO="11111111" status="Failed"/></FailedRecords></CapAdjustmentResponse>'
      end

      it 'return false' do
        expect(request.post).not_to be_success
      end
    end

    context 'when the response status is successful and the body does not contain an error' do
      let(:response_body) do
        '<CapAdjustmentResponse dateTime="2020-09-14T21:55:37Z" payloadID="11111111-1111-1111-1111-111111111111"><HeaderResult piMessageID="11111111111111111111111111111111" status="Success"/><FailedRecords/></CapAdjustmentResponse>'
      end

      it 'return true' do
        expect(request.post).to be_success
      end
    end
  end
end
