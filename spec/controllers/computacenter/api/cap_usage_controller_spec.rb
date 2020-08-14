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

  describe 'POST bulk_update' do
    context 'with no Authorization header' do
      it 'responds with :unauthorized' do
        post :bulk_update, body: cap_usage_update_packet
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
        post :bulk_update, body: cap_usage_update_packet
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with a valid auth token' do
      let(:auth_header) { "Bearer #{api_token.token}" }

      before do
        request.headers['Authorization'] = auth_header
      end

      it 'responds with a 2XX status' do
        post :bulk_update, body: cap_usage_update_packet
        expect(response).to have_http_status(204)
      end
    end
  end
end
