require 'rails_helper'

RSpec.describe AllocationChange, type: :model do
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

    before do
      stub_computacenter_outgoing_api_calls
      stub_sentry_outgoing_api_calls
    end

    context 'when fewer devices than the allocation are ordered' do
      it 'does not record an over order' do
        puts "std_device_allocation: #{std_device_allocation.inspect}"
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.to change(described_class, :count).by(0)
        puts "described_class: #{described_class.all}"
      end

      it 'does not change the allocation value' do
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.not_to change(std_device_allocation, :raw_allocation)
      end
    end

    context 'when more devices than the allocation are ordered in a pool' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_centrally_managed_schools_fully_ordered) }

      it 'records the over order' do
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.to change(described_class, :count).by(1)
      end

      it 'records the over order with the correct category' do
        std_device_allocation.devices_ordered += 1
        expect { std_device_allocation.save! }.to change(described_class.over_order, :count).by(1)
      end

      xit 'increases the allocation to match devices ordered' do
        std_device_allocation.devices_ordered += 1
        std_device_allocation.save!
        expect { std_device_allocation.raw_allocation }.to eq(std_device_allocation.devices_ordered)
      end

      xit 'notifies Sentry with a list of skipped trust ids' do
        sentry_scope = double
        allow(sentry_scope).to receive(:set_context)

        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope)

        service.update_trusts

        expect(Sentry).to have_received(:capture_message).with(/Unable to reclaim all of the allocation in the vcap to cover the over-order/)
        expect(sentry_scope).to have_received(:set_context).with(
          'AllocationOverOrderService#reclaim_allocation_across_virtual_cap_pool',
          { trust_ids: a_collection_containing_exactly(vcap_pool.id, remaining_over_ordered_quantity) },
        )
      end
    end
  end
end
