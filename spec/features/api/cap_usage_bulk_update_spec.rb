require 'rails_helper'

RSpec.feature 'Bulk cap usage update with XML', type: :request do
  let(:user) { create(:computacenter_user) }
  let(:api_token) { create(:api_token, status: :active, user: user) }
  let(:headers) { { 'Authorization' => "Bearer #{api_token.token}" } }
  let(:payload_id) { 'IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123' }
  let(:cap_usage_update_packet) do
    <<~XML
      <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
        <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="100" usedCap="20"/>
        <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060874" capAmount="200" usedCap="100"/>
        <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060875" capAmount="300" usedCap="57"/>
        <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060875" capAmount="400" usedCap="100"/>
        <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060876" capAmount="500" usedCap="200"/>
        <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060876" capAmount="600" usedCap="267"/>
      </CapUsage>
    XML
  end

  context 'all the records processed' do
    before do
      create(:school, computacenter_reference: '81060874', laptops: [100, 100, 0], routers: [100, 100, 0])
      create(:school, computacenter_reference: '81060875', laptops: [300, 100, 0], routers: [400, 100, 0])
      create(:school, computacenter_reference: '81060876', laptops: [500, 100, 0], routers: [600, 100, 0])
    end

    it 'returns ok and expected XML' do
      post computacenter_api_cap_usage_bulk_update_path(format: :xml), params: cap_usage_update_packet, headers: headers
      parsed_xml = Hash.from_xml(response.body)

      expect(response.status).to eq(200)
      expect(parsed_xml['CapUsageResponse']['payloadId']).to eq(payload_id)
      expect(parsed_xml['CapUsageResponse']['HeaderResult']['status']).to eq('succeeded')
      expect(parsed_xml['CapUsageResponse']['HeaderResult']['FailedRecords']).to be_blank
    end
  end

  context 'none of the shipTos exists on the platform' do
    it 'returns unprocessable_entity and all failed records in the XML' do
      post computacenter_api_cap_usage_bulk_update_path(format: :xml), params: cap_usage_update_packet, headers: headers
      parsed_xml = Hash.from_xml(response.body)

      expect(response.status).to eq(422)
      expect(parsed_xml['CapUsageResponse']['payloadId']).to eq(payload_id)
      expect(parsed_xml['CapUsageResponse']['HeaderResult']['status']).to eq('failed')
      expect(parsed_xml['CapUsageResponse']['HeaderResult']['FailedRecords']['Record'].count).to eq(6)
    end
  end

  context 'some schools do not exist' do
    before do
      create(:school, computacenter_reference: '81060874', laptops: [100, 100, 0], routers: [100, 100, 0])
    end

    it 'returns multi_status and the failed records in the XML' do
      post computacenter_api_cap_usage_bulk_update_path(format: :xml), params: cap_usage_update_packet, headers: headers
      parsed_xml = Hash.from_xml(response.body)

      expect(response.status).to eq(207)
      expect(parsed_xml['CapUsageResponse']['payloadId']).to eq(payload_id)
      expect(parsed_xml['CapUsageResponse']['HeaderResult']['status']).to eq('partially_failed')
      expect(parsed_xml['CapUsageResponse']['HeaderResult']['FailedRecords']['Record'].count).to eq(4)
    end
  end
end
