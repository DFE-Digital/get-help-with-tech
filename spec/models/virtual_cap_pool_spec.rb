require 'rails_helper'

RSpec.describe VirtualCapPool, type: :model do
  let(:local_authority) { create(:local_authority, :vcap_feature_flag) }

  subject(:pool) { local_authority.std_device_pool }

  describe '#recalculate_caps!' do
    let(:schools) { create_list(:school, 2, :centrally_managed, :with_std_device_allocation, :in_lockdown, responsible_body: local_authority) }

    before do
      stub_computacenter_outgoing_api_calls(response_body: 'test-response')
      schools.first.std_device_allocation.update!(cap: 2, allocation: 3, devices_ordered: 1)
      schools.last.std_device_allocation.update!(cap: 1, allocation: 3, devices_ordered: 1)
      schools.each do |school|
        AddSchoolToVirtualCapPoolService.new(school).call
      end
    end

    it 'recalculates the cap and devices_ordered totals for the schools in the pool' do
      schools.first.std_device_allocation.update!(cap: 3, allocation: 3, devices_ordered: 2)

      pool.recalculate_caps!

      expect(pool.cap).to eq(4)
      expect(pool.devices_ordered).to eq(3)
    end

    it 'stores the request and response against the allocations' do
      schools.first.std_device_allocation.update!(cap: 40, allocation: 40, devices_ordered: 26)
      pool.recalculate_caps!
      pool.school_device_allocations.each do |allocation|
        allocation.reload
        expect(allocation.cap_update_calls).to be_present
        expect(allocation.cap_update_calls.last.response_body).to include('test-response')
      end
    end

    it 'notifies computacenter regardless of the school status' do
      schools.first.update!(order_state: 'can_order')
      schools.last.update!(order_state: 'cannot_order')
      pool.school_device_allocations.each do |allocation|
        allocation.update!(devices_ordered: 3)
        allocation.cap_update_calls.destroy_all
      end
      pool.recalculate_caps!
      pool.school_device_allocations.each do |allocation|
        allocation.reload
        expect(allocation.cap_update_calls).to be_present
      end
    end

    context 'when cap or devices_ordered have not changed' do
      before do
        VirtualCapPool.no_touching do
          pool.schools.each do |s|
            s.std_device_allocation.update!(cap_update_request_payload_id: nil)
          end
        end
      end

      it 'does not notify computacenter of the change' do
        pool.schools.first.std_device_allocation.update!(allocation: 70)
        pool.reload.recalculate_caps!
        pool.school_device_allocations.each do |allocation|
          allocation.reload
          expect(allocation.cap_update_request_payload_id).to be_nil
        end
      end
    end

    context 'when cap or devices_ordered have changed' do
      it 'notifies computacenter of changes' do
        schools.first.std_device_allocation.update!(cap: 3, allocation: 3, devices_ordered: 2)
        pool.reload.recalculate_caps!
        pool.school_device_allocations.each do |allocation|
          allocation.reload
          expect(allocation.cap_update_request_payload_id).not_to be_nil
        end
      end
    end
  end

  describe '#has_school?' do
    before do
      stub_computacenter_outgoing_api_calls(response_body: 'test-response')
    end

    context 'with some schools on the pool' do
      let(:schools) { create_list(:school, 2, :centrally_managed, :with_std_device_allocation, :in_lockdown, responsible_body: local_authority) }

      before do
        schools.first.std_device_allocation.update!(cap: 2, allocation: 3, devices_ordered: 1)
        schools.last.std_device_allocation.update!(cap: 1, allocation: 3, devices_ordered: 1)

        AddSchoolToVirtualCapPoolService.new(schools.first).call
      end

      it 'returns true for a school on the pool' do
        expect(pool.has_school?(schools.first)).to be true
      end

      it 'returns false for a school not on the pool' do
        expect(pool.has_school?(schools.last)).to be false
      end
    end
  end

  describe '#devices_available_to_order' do
    subject(:allocation) { described_class.new(cap: 1, devices_ordered: 2) }

    context 'when negative' do
      it 'returns zero' do
        expect(allocation.devices_available_to_order).to be_zero
      end
    end
  end

  describe '#devices_available_to_order?' do
    context 'when used full allocation' do
      let(:allocation) { described_class.new(cap: 1, allocation: 1, devices_ordered: 1) }

      it 'returns false' do
        expect(allocation.devices_available_to_order?).to be false
      end
    end

    context 'when partially used allocation' do
      let(:allocation) { described_class.new(cap: 2, allocation: 2, devices_ordered: 1) }

      it 'returns true' do
        expect(allocation.devices_available_to_order?).to be true
      end
    end

    context 'when no devices ordered' do
      let(:allocation) { described_class.new(cap: 1, allocation: 1, devices_ordered: 0) }

      it 'returns true' do
        expect(allocation.devices_available_to_order?).to be true
      end
    end
  end
end
