require 'rails_helper'

RSpec.describe SchoolDeviceAllocation, type: :model do
  describe '#cap_implied_by_order_state' do
    subject(:allocation) { described_class.new(allocation: 27, cap: nil, devices_ordered: 13) }

    context 'given cannot_order' do
      it 'returns the value of devices_ordered' do
        expect(allocation.cap_implied_by_order_state(order_state: 'cannot_order')).to eq(13)
      end
    end

    context 'given can_order' do
      it 'returns the value of allocation' do
        expect(allocation.cap_implied_by_order_state(order_state: 'can_order')).to eq(27)
      end
    end

    context 'given can_order_for_specific_circumstances' do
      it 'returns the given cap' do
        expect(allocation.cap_implied_by_order_state(order_state: 'can_order_for_specific_circumstances', given_cap: 17)).to eq(17)
      end
    end
  end
end
