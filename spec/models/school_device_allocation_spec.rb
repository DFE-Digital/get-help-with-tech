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

  describe 'validations' do
    let(:school) { build(:school) }

    context 'cap exceeds allocation' do
      subject(:allocation) { described_class.new(cap: 11, allocation: 10, school: school) }

      it 'fails validation' do
        expect(allocation.valid?).to be_falsey
        expect(allocation.errors).to have_key(:cap)
        expect(allocation.errors[:cap]).to include('can’t be greater than allocation')
      end
    end

    context 'cap equals allocation' do
      subject(:allocation) { described_class.new(cap: 10, allocation: 10, school: school) }

      it 'passes validation' do
        expect(allocation.valid?).to be_truthy
      end
    end

    context 'cap less than devices_ordered' do
      subject(:allocation) do
        described_class.new(cap: 9,
                            devices_ordered: 10,
                            allocation: 100,
                            school: school)
      end

      it 'passes validation' do
        expect(allocation.valid?).to be_truthy
      end
    end

    context 'cap equals devices_ordered' do
      subject(:allocation) do
        described_class.new(cap: 10,
                            devices_ordered: 10,
                            allocation: 100,
                            school: school)
      end

      it 'passes validation' do
        expect(allocation.valid?).to be_truthy
      end
    end
  end

  describe '#available_devices_count' do
    subject(:allocation) { described_class.new(cap: 100, devices_ordered: 200) }

    context 'when negative' do
      it 'returns zero' do
        expect(allocation.available_devices_count).to be_zero
      end
    end
  end
end
