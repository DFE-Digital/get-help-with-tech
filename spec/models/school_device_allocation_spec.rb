require 'rails_helper'

RSpec.describe SchoolDeviceAllocation, type: :model do
  it { is_expected.to be_versioned }

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

    context 'within a virtual cap' do
      let(:responsible_body) { create(:trust, :vcap_feature_flag) }
      let(:schools) { create_list(:school, 2, :with_preorder_information, :with_std_device_allocation, :in_lockdown, responsible_body: responsible_body) }

      let(:school) { schools.first }
      let(:allocation) { school.std_device_allocation.reload }

      before do
        stub_computacenter_outgoing_api_calls

        schools.each do |school|
          school.std_device_allocation.update!(allocation: 27, cap: 0, devices_ordered: 13, school: school)

          school.preorder_information.update!(who_will_order_devices: 'responsible_body')
          school.can_order!
          responsible_body.add_school_to_virtual_cap_pools!(school)
          responsible_body.calculate_virtual_caps!
        end
      end

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

  describe '#devices_available_to_order' do
    subject(:allocation) { described_class.new(cap: 100, devices_ordered: 200) }

    context 'when negative' do
      it 'returns zero' do
        expect(allocation.devices_available_to_order).to be_zero
      end
    end
  end

  describe '#allocation' do
    subject(:allocation) { described_class.new(cap: 100, devices_ordered: 50, allocation: 100) }

    it 'refers to the local allocation' do
      expect(allocation.allocation).to eq(allocation.raw_allocation)
    end
  end

  describe '#cap' do
    subject(:allocation) { described_class.new(cap: 100, devices_ordered: 50, allocation: 100) }

    it 'refers to the local cap' do
      expect(allocation.cap).to eq(allocation.raw_cap)
    end
  end

  describe '#devices_ordered' do
    subject(:allocation) { described_class.new(cap: 100, devices_ordered: 50, allocation: 100) }

    it 'refers to the local devices_ordered' do
      expect(allocation.devices_ordered).to eq(allocation.raw_devices_ordered)
    end
  end

  describe '#computacenter_cap' do
    subject(:allocation) { described_class.new(cap: 100, devices_ordered: 50, allocation: 100) }

    it 'returns the cap amount for computacenter' do
      expect(allocation.computacenter_cap).to eq(allocation.raw_cap)
    end
  end

  context 'when in a virtual pool' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
    let(:school) { create(:school, :with_preorder_information, :in_lockdown, responsible_body: responsible_body) }
    let(:school2) { create(:school, :with_preorder_information, :in_lockdown, responsible_body: responsible_body) }
    let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789', body: '<xml>test-request</xml>') }
    let(:response) { OpenStruct.new(body: '<xml>test-response</xml>') }

    subject(:allocation) { described_class.create!(device_type: 'std_device', cap: 100, devices_ordered: 87, allocation: 120, school: school) }

    before do
      allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
      allow(mock_request).to receive(:post!).and_return(response)

      allocation
      school.orders_managed_centrally!
      school2.orders_managed_centrally!
      school2.device_allocations.std_device.create!(allocation: 200, cap: 100, devices_ordered: 50)
      responsible_body.add_school_to_virtual_cap_pools!(school)
      responsible_body.add_school_to_virtual_cap_pools!(school2)
      allocation.reload
    end

    it 'performs validation on the local values' do
      allocation.cap = 121
      expect(allocation.valid?).to be false
    end

    it 'propagates changes up to the pool' do
      allocation.update!(allocation: 400, cap: 300, devices_ordered: 200)
      responsible_body.std_device_pool.reload
      expect(responsible_body.std_device_pool.allocation).to eq(600)
      expect(responsible_body.std_device_pool.cap).to eq(400)
      expect(responsible_body.std_device_pool.devices_ordered).to eq(250)
    end

    it 'receives cap updates from the pool' do
      allocation.update!(allocation: 400, cap: 300, devices_ordered: 200)
      allocation.reload
      expect(allocation.cap_update_calls).to be_present
      expect(allocation.cap_update_calls.last.failure).to be false
      expect(allocation.cap_update_calls.last.request_body).to include('test-request')
      expect(allocation.cap_update_calls.last.response_body).to include('test-response')
    end

    describe '#allocation' do
      it 'refers to the pool allocation instead of local version' do
        pool = responsible_body.std_device_pool
        expect(allocation.allocation).to eq(pool.allocation)
        expect(allocation.raw_allocation).to eq(120)
      end
    end

    describe '#cap' do
      it 'refers to the pool cap instead of local version' do
        pool = responsible_body.std_device_pool
        expect(allocation.cap).to eq(pool.cap)
        expect(allocation.raw_cap).to eq(100)
      end
    end

    describe '#devices_ordered' do
      it 'refers to the pool devices_ordered instead of the local version' do
        pool = responsible_body.std_device_pool
        expect(allocation.devices_ordered).to eq(pool.devices_ordered)
        expect(allocation.raw_devices_ordered).to eq(87)
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
