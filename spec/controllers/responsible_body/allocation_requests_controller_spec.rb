require 'rails_helper'

RSpec.describe ResponsibleBody::AllocationRequestsController, type: :controller do
  describe '#create_or_update' do
    it 'handles valid submissions' do
      sign_in_as create(:local_authority_user)

      post :create_or_update, params: {
        allocation_request: {
          number_eligible: '5',
          number_eligible_with_hotspot_access: '3',
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(AllocationRequest.count).to eq(1)

      allocation_request = AllocationRequest.first
      expect(allocation_request.number_eligible).to eq(5)
      expect(allocation_request.number_eligible_with_hotspot_access).to eq(3)
    end

    it 'handles invalid submissions' do
      sign_in_as create(:local_authority_user)

      post :create_or_update, params: {
        allocation_request: {
          number_eligible: 'x',
          number_eligible_with_bt_hotspots: 'y',
        }
      }

      expect(response).to have_http_status(:bad_request)
      expect(AllocationRequest.count).to eq(0)
    end
  end
end
