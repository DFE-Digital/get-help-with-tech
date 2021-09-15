require 'rails_helper'

RSpec.describe Computacenter::API::CapUsageController do
  let(:user) { create(:computacenter_user) }
  let(:api_token) { create(:api_token, status: :active, user: user) }
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

  describe 'Authentication' do
    context 'with no Authorization header' do
      it 'responds with :unauthorized' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with an auth token from a non-computacenter_user' do
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
    end

    context 'given valid XML but where the usedCap is negative' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
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
          <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="-1" usedCap="2"/>
          </CapUsage>
        XML
      end

      it 'responds with a 400 status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST bulk_update with valid auth and valid XML' do
    let(:cap_usage_update_packet) do
      <<~XML
        <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
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
        @school1 = create(:school, computacenter_reference: '81060874')
        @school2 = create(:school, computacenter_reference: '81060875')

        create(:school_device_allocation, school: @school1, device_type: 'std_device', cap: 100, allocation: 100)
        create(:school_device_allocation, school: @school1, device_type: 'coms_device', cap: 100, allocation: 100)

        create(:school_device_allocation, school: @school2, device_type: 'std_device', cap: 100, allocation: 300)
        create(:school_device_allocation, school: @school2, device_type: 'coms_device', cap: 100, allocation: 400)
      end

      it 'responds with :ok status and updates the records' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)

        expect(@school1.reload.laptops_ordered).to eq(20)
        expect(@school1.reload.routers_ordered).to eq(100)

        expect(@school2.reload.laptops_ordered).to eq(57)
        expect(@school2.reload.routers_ordered).to eq(100)
      end
    end

    context 'when the used cap and cap amount are zero' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="0" usedCap="0"/>
          </CapUsage>
        XML
      end

      before do
        school = create(:school, computacenter_reference: '81060874')
        create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 0)
      end

      it 'is treated a valid payload' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the used cap is greater than cap amount (see Trello card #716)' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="10" usedCap="37"/>
          </CapUsage>
        XML
      end

      let(:school) { create(:school, computacenter_reference: '81060874') }

      before do
        create(:school_device_allocation, school: school, device_type: 'std_device', allocation: 0)
      end

      it 'is treated a valid payload' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)
        expect(school.reload.laptops_ordered).to eq(37)
      end
    end

    context 'when all updates failed' do
      it 'responds with :unprocessable_entity status' do
        # no schools are seeded in the DB so there will be a data mismatch for all records
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when some but not all updates failed' do
      before do
        # only 1 of 2 schools there so partial failure
        school1 = create(:school, computacenter_reference: '81060874')
        create(:school_device_allocation, school: school1, device_type: 'std_device', cap: 100, allocation: 100)
        create(:school_device_allocation, school: school1, device_type: 'coms_device', cap: 100, allocation: 100)
      end

      it 'responds with :multi_status status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet
        expect(response).to have_http_status(:multi_status)
      end
    end

    context 'when only a single record is being updated (XML parsing works slightly differently)' do
      let(:cap_usage_update_packet) do
        <<~XML
          <CapUsage payloadID="IDGAAC47B3HSQAQ2EH0LQ1G_SRI_TEST_123" dateTime="2020-06-18T09:20:45Z" >
            <Record capType="DfE_RemainThresholdQty|Std_Device" shipTo="81060874" capAmount="100" usedCap="20"/>
          </CapUsage>
        XML
      end

      before do
        @school = create(:school, computacenter_reference: '81060874')
        create(:school_device_allocation, school: @school, device_type: 'std_device', cap: 100, allocation: 100)
      end

      it 'responds with :multi_status status' do
        post :bulk_update, format: :xml, body: cap_usage_update_packet

        expect(response).to have_http_status(:ok)
        expect(@school.reload.laptops_ordered).to eq(20)
      end
    end
  end
end
