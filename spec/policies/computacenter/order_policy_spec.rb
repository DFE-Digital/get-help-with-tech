require 'rails_helper'

describe Computacenter::OrderPolicy do
  let!(:orders) { create_list(:computacenter_order, 2) }
  let(:scope) { Pundit.policy_scope!(current_user, Computacenter::Order) }

  describe 'scope' do
    context 'when user is a support user' do
      let(:current_user) { build(:support_user) }

      it 'returns all orders' do
        expect(scope).to match_array(orders)
      end
    end

    context 'when user is a computacenter user' do
      let(:current_user) { build(:computacenter_user) }

      it 'returns all orders' do
        expect(scope).to match_array(orders)
      end
    end

    context 'when user is a local authority user and the local authority has no orders' do
      let(:current_user) { build(:local_authority_user) }

      it 'returns no orders' do
        expect(scope).to be_empty
      end
    end

    context 'when user is a local authority user and the local authority has orders' do
      let(:current_user) { local_authority_user }
      let(:local_authority) { local_authority_user.rb }
      let!(:local_authority_order) { create(:computacenter_order, sold_to: local_authority.computacenter_reference) }
      let(:local_authority_user) { create(:local_authority_user) }

      it 'returns only the local authority orders' do
        expect(scope).to match_array(local_authority_order)
      end
    end

    context 'when user is a school user and the school has no orders' do
      let(:current_user) { build(:school_user) }

      it 'returns no orders' do
        expect(scope).to be_empty
      end
    end

    context 'when user is a school user and the school has orders' do
      let(:current_user) { school_user }
      let(:school) { school_user.school }
      let!(:school_order) { create(:computacenter_order, ship_to: school.computacenter_reference) }
      let(:school_user) { create(:school_user) }

      it 'returns only the school orders' do
        expect(scope).to match_array(school_order)
      end
    end
  end
end
