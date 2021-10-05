require 'rails_helper'

RSpec.describe SchoolDeviceAllocation, type: :model do
  it { is_expected.to be_versioned }

  describe 'validations' do
    let(:school) { build(:school) }

    context 'cap exceeds allocation' do
      subject(:allocation) { build_stubbed(:school_device_allocation, cap: 2, allocation: 1, school: school) }

      it 'fails validation' do
        expect(allocation.valid?).to be_falsey
        expect(allocation.errors).to have_key(:cap)
        expect(allocation.errors[:cap]).to include('can’t be greater than allocation')
      end
    end

    context 'cap equals allocation' do
      subject(:allocation) { build_stubbed(:school_device_allocation, cap: 1, allocation: 1, school: school) }

      it 'passes validation' do
        expect(allocation.valid?).to be_truthy
      end
    end

    context 'cap less than devices_ordered' do
      subject(:allocation) do
        build_stubbed(:school_device_allocation,
                      cap: 1,
                      devices_ordered: 2,
                      allocation: 2,
                      school: school)
      end

      it 'passes validation' do
        expect(allocation.valid?).to be_truthy
      end
    end

    context 'cap equals devices_ordered' do
      subject(:allocation) do
        build_stubbed(:school_device_allocation,
                      cap: 1,
                      devices_ordered: 1,
                      allocation: 2,
                      school: school)
      end

      it 'passes validation' do
        expect(allocation.valid?).to be_truthy
      end
    end
  end

  describe '#devices_available_to_order' do
    subject(:allocation) { build_stubbed(:school_device_allocation, cap: cap, devices_ordered: 2) }

    context 'when more devices ordered than the assigned cap' do
      let(:cap) { 1 }

      it 'returns zero' do
        expect(allocation.devices_available_to_order).to be_zero
      end
    end

    context 'when no more devices ordered than the assigned cap' do
      let(:cap) { 3 }

      it 'returns the difference' do
        expect(allocation.devices_available_to_order).to eq(1)
      end
    end
  end

  describe '#devices_available_to_order?' do
    subject(:allocation) { build_stubbed(:school_device_allocation, cap: cap, allocation: cap, devices_ordered: 1) }

    context 'when used full allocation' do
      let(:cap) { 1 }

      it 'returns false' do
        expect(allocation.devices_available_to_order?).to be false
      end
    end

    context 'when used over allocation' do
      let(:cap) { 0 }

      it 'returns false' do
        expect(allocation.devices_available_to_order?).to be false
      end
    end

    context 'when partially used allocation' do
      let(:cap) { 2 }

      it 'returns true' do
        expect(allocation.devices_available_to_order?).to be true
      end
    end
  end

  describe '#allocation' do
    subject(:allocation) { build_stubbed(:school_device_allocation, cap: 2, devices_ordered: 1, allocation: 2) }

    it 'refers to the local allocation' do
      expect(allocation.allocation).to eq(allocation.raw_allocation)
    end
  end

  describe '#cap' do
    subject(:allocation) { build_stubbed(:school_device_allocation, cap: 2, devices_ordered: 1, allocation: 2) }

    it 'refers to the local cap' do
      expect(allocation.cap).to eq(allocation.raw_cap)
    end
  end

  describe '#devices_ordered' do
    subject(:allocation) { build_stubbed(:school_device_allocation, cap: 1, devices_ordered: 0, allocation: 1) }

    it 'refers to the local devices_ordered' do
      expect(allocation.devices_ordered).to eq(allocation.raw_devices_ordered)
    end
  end

  describe '#computacenter_cap' do
    subject(:allocation) { build_stubbed(:school_device_allocation, cap: 2, devices_ordered: 1, allocation: 2) }

    it 'returns the cap amount for computacenter' do
      expect(allocation.computacenter_cap).to eq(allocation.raw_cap)
    end
  end

  context 'when fewer devices than the allocation are ordered' do
    let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }
    let(:std_device_allocation) { school.std_device_allocation }

    it 'does not change the allocation value' do
      std_device_allocation.devices_ordered += 1
      expect { std_device_allocation.save! }.not_to change(std_device_allocation, :raw_allocation)
    end
  end

  context 'when more devices than the allocation are ordered' do
    let(:school) { create(:school, :with_std_device_allocation_fully_ordered) }
    let(:std_device_allocation) { school.std_device_allocation }

    it 'increases the allocation to match devices ordered' do
      stub_computacenter_outgoing_api_calls
      std_device_allocation.devices_ordered += 1
      std_device_allocation.save!
      expect(std_device_allocation.devices_ordered).to eq(std_device_allocation.raw_allocation)
    end
  end

  context 'when in a virtual pool' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
    let(:school) { create(:school, :manages_orders, :in_lockdown, responsible_body: responsible_body) }
    let(:school2) { create(:school, :manages_orders, :in_lockdown, responsible_body: responsible_body) }
    let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789', body: '<xml>test-request</xml>') }
    let(:response) { OpenStruct.new(body: '<xml>test-response</xml>') }

    subject(:allocation) do
      create(:school_device_allocation,
             device_type: 'std_device',
             cap: 2,
             devices_ordered: 1,
             allocation: 3,
             school: school)
    end

    before do
      stub_computacenter_outgoing_api_calls(response_body: 'test-response')
      allocation
      school2.device_allocations.std_device.create!(allocation: 3, cap: 2, devices_ordered: 1)
      school.orders_managed_centrally!
      school2.orders_managed_centrally!
      responsible_body.reload
      allocation.reload
    end

    it 'performs validation on the local values' do
      allocation.cap = 4
      expect(allocation).not_to be_valid
    end

    it 'propagates changes up to the pool' do
      allocation.update!(allocation: 4, cap: 3, devices_ordered: 2)
      responsible_body.std_device_pool.reload
      expect(responsible_body.std_device_pool.allocation).to eq(7)
      expect(responsible_body.std_device_pool.cap).to eq(5)
      expect(responsible_body.std_device_pool.devices_ordered).to eq(3)
    end

    it 'receives cap updates from the pool' do
      allocation.update!(allocation: 4, cap: 3, devices_ordered: 2)
      allocation.reload
      expect(allocation.cap_update_calls).to be_present
      expect(allocation.cap_update_calls.last.failure).to be false
      expect(allocation.cap_update_calls.last.response_body).to include('test-response')
    end

    describe '#allocation' do
      it 'refers to the pool allocation instead of local version' do
        pool = responsible_body.std_device_pool
        expect(allocation.allocation).to eq(pool.allocation)
        expect(allocation.raw_allocation).to eq(3)
      end
    end

    describe '#cap' do
      it 'refers to the pool cap instead of local version' do
        pool = responsible_body.std_device_pool
        expect(allocation.cap).to eq(pool.cap)
        expect(allocation.raw_cap).to eq(2)
      end
    end

    describe '#devices_ordered' do
      it 'refers to the pool devices_ordered instead of the local version' do
        pool = responsible_body.std_device_pool
        expect(allocation.devices_ordered).to eq(pool.devices_ordered)
        expect(allocation.raw_devices_ordered).to eq(1)
      end
    end

    describe '#computacenter_cap' do
      it 'returns an adjusted cap amount for computacenter' do
        pool = responsible_body.std_device_pool
        expected = pool.cap - pool.devices_ordered + allocation.raw_devices_ordered
        expect(allocation.computacenter_cap).to eq(expected)
      end
    end
  end
end
