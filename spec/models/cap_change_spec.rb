require 'rails_helper'

RSpec.describe CapChange, type: :model do
  before { stub_computacenter_outgoing_api_calls }

  context 'when the school manages the allocation' do
    context 'when no more devices than the allocation are ordered' do
      let(:school) { create(:school, :in_lockdown, laptops: [2, 2, 1]) }

      it 'does not record an over order' do
        expect {
          UpdateSchoolDevicesService.new(school: school, laptops_ordered: 2).call
        }.to change(described_class, :count).by(0)
      end
    end

    context 'when more devices than the allocation are ordered' do
      let(:school) { create(:school, laptops: [1, 1, 1]) }

      it 'records the allocation change' do
        expect {
          UpdateSchoolDevicesService.new(school: school,
                                         laptops_ordered: 0,
                                         cap_change_category: :service_closure).call
        }.to change(described_class, :count).by(1)
      end

      it 'records the allocation change with the correct category' do
        expect {
          UpdateSchoolDevicesService.new(school: school, laptops_ordered: 2).call
        }.to change(described_class.over_order, :count).by(1)
      end
    end
  end

  context 'when the allocation is pooled' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_centrally_managed_schools) }
    let(:school) { responsible_body.schools.first }

    context 'when fewer devices than the allocation are ordered' do
      it 'does not record an over order' do
        expect {
          UpdateSchoolDevicesService.new(school: school, laptops_ordered: 2).call
        }.to change(described_class, :count).by(0)
      end

      it 'does not change the allocation value' do
        school.raw_laptops_ordered += 1
        expect { school.save! }.not_to(change { school.raw_allocation(:laptop) })
      end
    end

    context 'when more devices than the allocation are ordered in a pool' do
      let(:alert) { 'Unable to reclaim all of the cap in the vcap to cover the over-order' }
      let(:non_allocated_but_ordered_devices) { 1 }
      let(:sentry_context_key) { 'AllocationOverOrderService#reclaim_cap_across_virtual_cap_pool' }
      let(:sentry_context_value) do
        {
          device_type: :laptop,
          remaining_over_ordered_quantity: non_allocated_but_ordered_devices,
          school_id: school.id,
        }
      end
      let(:sentry_scope) { instance_spy(Sentry::Scope, set_context: :great) }
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_centrally_managed_schools_fully_ordered) }

      before do
        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:with_scope).and_yield(sentry_scope)
      end

      it 'records the over order' do
        expect {
          UpdateSchoolDevicesService.new(school: school, laptops_ordered: 3).call
        }.to change(described_class, :count).by(1)
      end

      it 'records the over order with the correct category' do
        expect {
          UpdateSchoolDevicesService.new(school: school, laptops_ordered: 3).call
        }.to change(described_class.over_order, :count).by(1)
      end

      it 'increases the cap to match devices ordered' do
        UpdateSchoolDevicesService.new(school: school, laptops_ordered: 3).call
        expect(school.raw_cap(:laptop)).to eq(school.raw_devices_ordered(:laptop))
      end

      it 'informs Sentry' do
        UpdateSchoolDevicesService.new(school: school, laptops_ordered: 3).call
        expect(Sentry).to have_received(:capture_message).with(alert)
        expect(sentry_scope).to have_received(:set_context).with(sentry_context_key, sentry_context_value)
      end
    end
  end
end
