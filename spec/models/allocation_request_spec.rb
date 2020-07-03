require 'rails_helper'

RSpec.describe AllocationRequest, type: :model do
  describe 'responsible_body_id' do
    let(:trust) { create :trust }
    let(:user) { create :trust_user, responsible_body: trust }

    context 'creating without responsible body' do
      it "uses the user's responsible body" do
        allocation_request = AllocationRequest.create(
          number_eligible: 10,
          number_eligible_with_hotspot_access: 4,
          created_by_user: user,
        )

        expect(allocation_request.responsible_body).to eq trust
      end
    end

    context 'creating with a responsible body set' do
      let(:other_trust) { create :trust }

      it 'uses the given responsible body' do
        allocation_request = AllocationRequest.create(
          number_eligible: 10,
          number_eligible_with_hotspot_access: 4,
          created_by_user: user,
          responsible_body: other_trust,
        )

        expect(allocation_request.responsible_body).to eq other_trust
      end
    end

    context 'creating without user or responsible body' do
      it 'raises an error' do
        AllocationRequest.create(
          number_eligible: 10,
          number_eligible_with_hotspot_access: 4,
        )
      end
    end
  end
end
