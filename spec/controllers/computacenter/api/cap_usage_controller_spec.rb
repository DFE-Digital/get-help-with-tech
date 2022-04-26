require 'rails_helper'

RSpec.describe Computacenter::API::CapUsageController, skip: true do
  let(:user) { create(:computacenter_user) }
  let(:api_token) { create(:api_token, status: :active, user:) }
  let(:cap_usage_update_packet) do
    <<~XML
      <CapUsage payloadID="45520C4CEEEF4CACAB2603847F08EFA2" dateTime="2020-06-18T09:20:45Z" >
        <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="100" usedCap="20"/>
        <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060874" capAmount="200" usedCap="100"/>
        <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060875" capAmount="300" usedCap="57"/>
        <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060875" capAmount="400" usedCap="100"/>
        <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060876" capAmount="500" usedCap="200"/>
        <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060876" capAmount="600" usedCap="267"/>
      </CapUsage>
    XML
  end

  describe 'Authentication' do
    context 'with no Authorization header' do
      it 'responds with :unauthorized' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with an api token from a non-computacenter_user' do
      let(:other_user) { create(:mno_user) }
      let(:other_user_token) { create(:api_token, status: :active, user: other_user) }
      let(:auth_header) { "Bearer #{other_user_token.token}" }

      before do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with a :forbidden status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'expired api token' do
      let(:api_token) { create(:api_token, status: :active, user:, created_at: (APIToken::DEFAULT_TTL_DAYS + 1).days.ago) }

      before do
        request.headers['Authorization'] = "Bearer #{api_token.token}"
      end

      it 'responds with :unauthorized' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST bulk_update with valid auth but invalid XML' do
    let(:invalid_xml) do
      <<~XML
        <Broken Tag Structure>
          <with errors=here>and</here>
        </Broken>
      XML
    end

    before do
      request.headers['Authorization'] = "Bearer #{api_token.token}"
    end

    context 'given invalid XML' do
      it 'responds with a 400 status' do
        post :bulk_update, format: :xml, body: invalid_xml
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'given valid XML that does not conform to the schema' do
      let(:valid_xml_but_not_valid_for_the_schema) do
        <<~XML
          <NotACapUsagePacket>
            <SomethingElse>Entirely</SomethingElse>
          </NotACapUsagePacket>
        XML
      end

      it 'responds with a 400 status' do
        post :bulk_update, format: :xml, body: valid_xml_but_not_valid_for_the_schema
        expect(response).to have_http_status(:bad_request)
      end

      it 'stores just the xml' do
        post :bulk_update, format: :xml, body: valid_xml_but_not_valid_for_the_schema

        payload = Computacenter::API::CapUsageUpdatePayload.order(id: :desc).limit(1).first

        expect(payload.payload_id).to be_nil
        expect(payload.payload_xml).to eq(valid_xml_but_not_valid_for_the_schema)
        expect(payload.payload_timestamp).to be_nil
        expect(payload.status).to be_nil
        expect(payload.completed_at).to be_nil
      end
    end

    context 'given valid XML but where the usedCap is negative' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="45520C4CEEEF4CACAB2603847F08EFA2" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="0" usedCap="-1"/>
          </CapUsage>
        XML
      end

      it 'responds with a 400 status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'given valid XML but where the capAmount is negative' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="45520C4CEEEF4CACAB2603847F08EFA2" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="-1" usedCap="2"/>
          </CapUsage>
        XML
      end

      it 'responds with a 400 status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:bad_request)
      end

      it 'stores just the xml' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        payload = Computacenter::API::CapUsageUpdatePayload.order(id: :desc).limit(1).first

        expect(payload.payload_id).to be_nil
        expect(payload.payload_xml).to eq(cap_usage_update_packet)
        expect(payload.payload_timestamp).to be_nil
        expect(payload.records_count).to be_nil
        expect(payload.succeeded_count).to be_nil
        expect(payload.failed_count).to be_nil
        expect(payload.status).to be_nil
        expect(payload.completed_at).to be_nil
      end
    end
  end

  describe 'POST bulk_update with valid auth and valid XML' do
    let(:payload_id) { '45520C4CEEEF4CACAB2603847F08EFA2' }
    let(:payload_timestamp) { '2020-06-18T09:20:45Z' }

    let(:cap_usage_update_packet) do
      <<~XML
        <CapUsage payloadID="#{payload_id}" dateTime="#{payload_timestamp}" >
          <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="100" usedCap="20"/>
          <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060874" capAmount="200" usedCap="100"/>
          <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060875" capAmount="300" usedCap="57"/>
          <Record capType="DfE_RemainThresholdQty|Coms_Device" shipTo="81060875" capAmount="400" usedCap="100"/>
        </CapUsage>
      XML
    end

    before do
      request.headers['Authorization'] = "Bearer #{api_token.token}"
    end

    context 'when all updates succeed' do
      before do
        @school1 = create(:school, computacenter_reference: '81060874', laptops: [100, 100, 0], routers: [100, 100, 0])
        @school2 = create(:school, computacenter_reference: '81060875', laptops: [300, 100, 0], routers: [400, 100, 0])
      end

      it 'responds with :ok status and updates the records' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)

        expect(@school1.reload.devices_ordered(:laptop)).to eq(20)
        expect(@school1.reload.devices_ordered(:routers)).to eq(100)

        expect(@school2.reload.devices_ordered(:laptop)).to eq(57)
        expect(@school2.reload.devices_ordered(:router)).to eq(100)
      end

      it 'stores the payload with status succeeded and completed_at timestamp' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        payload = Computacenter::API::CapUsageUpdatePayload.order(id: :desc).limit(1).first

        expect(payload.payload_id).to eq(payload_id)
        expect(payload.payload_xml).to eq(cap_usage_update_packet)
        expect(payload.payload_timestamp).to eq(payload_timestamp)
        expect(payload.records_count).to eq(4)
        expect(payload.succeeded_count).to eq(4)
        expect(payload.failed_count).to eq(0)
        expect(payload.status).to eq('succeeded')
        expect(payload.completed_at).to be_present
      end
    end

    context 'when the used cap and cap amount are zero' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="45520C4CEEEF4CACAB2603847F08EFA2" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="0" usedCap="0"/>
          </CapUsage>
        XML
      end

      before do
        create(:school, computacenter_reference: '81060874')
      end

      it 'is treated a valid payload' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the used cap is greater than cap amount (see Trello card #716)' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="45520C4CEEEF4CACAB2603847F08EFA2" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="10" usedCap="37"/>
          </CapUsage>
        XML
      end

      let!(:school) { create(:school, computacenter_reference: '81060874') }

      it 'is treated a valid payload' do
        stub_computacenter_outgoing_api_calls
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)
        expect(school.reload.devices_ordered(:laptop)).to eq(37)
      end
    end

    context 'when all updates failed' do
      it 'responds with :unprocessable_entity status' do
        # no schools are seeded in the DB so there will be a data mismatch for all records
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'stores the payload with status failed and completed_at timestamp' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        payload = Computacenter::API::CapUsageUpdatePayload.order(id: :desc).limit(1).first

        expect(payload.payload_id).to eq(payload_id)
        expect(payload.payload_xml).to eq(cap_usage_update_packet)
        expect(payload.payload_timestamp).to eq(payload_timestamp)
        expect(payload.records_count).to eq(4)
        expect(payload.succeeded_count).to eq(0)
        expect(payload.failed_count).to eq(4)
        expect(payload.status).to eq('failed')
        expect(payload.completed_at).to be_present
      end
    end

    context 'when some but not all updates failed' do
      before do
        # only 1 of 2 schools there so partial failure
        create(:school, computacenter_reference: '81060874', laptops: [100, 100, 0], routers: [100, 100, 0])
      end

      it 'responds with :multi_status status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:multi_status)
      end

      it 'stores the payload with status partially_failed and completed_at timestamp' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        payload = Computacenter::API::CapUsageUpdatePayload.order(id: :desc).limit(1).first

        expect(payload.payload_id).to eq(payload_id)
        expect(payload.payload_xml).to eq(cap_usage_update_packet)
        expect(payload.payload_timestamp).to eq(payload_timestamp)
        expect(payload.records_count).to eq(4)
        expect(payload.succeeded_count).to eq(2)
        expect(payload.failed_count).to eq(2)
        expect(payload.status).to eq('partially_failed')
        expect(payload.completed_at).to be_present
      end
    end

    context 'when only a single record is being updated (XML parsing works slightly differently)' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="45520C4CEEEF4CACAB2603847F08EFA2" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="100" usedCap="20"/>
          </CapUsage>
        XML
      end

      let!(:school) { create(:school, computacenter_reference: '81060874', laptops: [100, 100, 0]) }

      it 'responds with :ok status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)
        expect(school.reload.devices_ordered(:laptop)).to eq(20)
      end
    end
  end
end
