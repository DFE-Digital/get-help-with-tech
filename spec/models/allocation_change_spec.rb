require 'rails_helper'

RSpec.describe AllocationChange, type: :model do
  before { stub_computacenter_outgoing_api_calls }

  context 'when the school manages the allocation' do
    context 'when fewer devices than the allocation are ordered' do
      let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }
      let(:std_device_allocation) { school.std_device_allocation }

      it 'does not record an over order' do
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.to change(described_class, :count).by(0)
      end
    end

    context 'when more devices than the allocation are ordered' do
      let(:school) { create(:school, :with_std_device_allocation_fully_ordered) }
      let(:std_device_allocation) { school.std_device_allocation }

      it 'records the allocation change' do
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.to change(described_class, :count).by(1)
      end

      it 'records the allocation change with the correct category' do
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.to change(described_class.over_order, :count).by(1)
      end
    end
  end

  context 'when the allocation is pooled' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_centrally_managed_schools) }
    let(:std_device_allocation) { responsible_body.schools.first.std_device_allocation }

    context 'when fewer devices than the allocation are ordered' do
      it 'does not record an over order' do
        std_device_allocation.devices_ordered = std_device_allocation.raw_devices_ordered + 1
        expect { std_device_allocation.save! }.to change(described_class, :count).by(0)
      end

      it 'does not change the allocation value' do
        std_device_allocation.devices_ordered = std_device_allocation.raw_devices_ordered + 1
        expect { std_device_allocation.save! }.not_to change(std_device_allocation, :raw_allocation)
      end
    end

    context 'when more devices than the allocation are ordered in a pool' do
      let(:alert) { 'Unable to reclaim all of the allocation in the vcap to cover the over-order' }
      let(:non_allocated_but_ordered_devices) { 1 }
      let(:sentry_context_key) { 'AllocationOverOrderService#reclaim_allocation_across_virtual_cap_pool' }
      let(:sentry_context_value) do
        {
          vcap_pool_id: responsible_body.std_device_pool.id,
          remaining_over_ordered_quantity: non_allocated_but_ordered_devices,
        }
      end
      let(:sentry_scope) { instance_spy(Sentry::Scope, set_context: :great) }

      before do
        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope)
      end

      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_centrally_managed_schools_fully_ordered) }

      it 'records the over order' do
        std_device_allocation.devices_ordered = std_device_allocation.raw_devices_ordered + 1
        expect { std_device_allocation.save! }.to change(described_class, :count).by(1)
      end

      it 'records the over order with the correct category' do
        std_device_allocation.devices_ordered = std_device_allocation.raw_devices_ordered + 1
        expect { std_device_allocation.save! }.to change(described_class.over_order, :count).by(1)
      end

      it 'increases the allocation to match devices ordered' do
        std_device_allocation.devices_ordered = std_device_allocation.raw_devices_ordered + 1
        std_device_allocation.save!
        expect(std_device_allocation.raw_allocation).to eq(std_device_allocation.raw_devices_ordered)
      end

      it 'informs Sentry' do
        std_device_allocation.devices_ordered = std_device_allocation.raw_devices_ordered + 1
        std_device_allocation.save!
        expect(Sentry).to have_received(:capture_message).with(alert)
        expect(sentry_scope).to have_received(:set_context).with(sentry_context_key, sentry_context_value)
      end
    end
  end
end
