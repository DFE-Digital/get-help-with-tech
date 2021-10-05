require 'rails_helper'

RSpec.describe AllocationOverOrderService, type: :model do
  describe '#call' do
    let(:rb) { create(:local_authority, :manages_centrally, :vcap_feature_flag) }

    before do
      stub_computacenter_outgoing_api_calls
    end

    context 'when the school is centrally managed in virtual cap pool' do
      let(:school) do
        create(:school,
               :centrally_managed,
               :with_std_device_allocation,
               responsible_body: rb,
               laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1)
      end

      let(:sibling_schools) do
        create_list(:school,
                    2,
                    :centrally_managed,
                    :with_std_device_allocation,
                    responsible_body: rb,
                    laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1)
      end

      before do
        (sibling_schools + [school]).each { |school| AddSchoolToVirtualCapPoolService.new(school).call }
        rb.reload
      end

      it 'get the extra devices ordered from the devices available in the pool' do
        allow(school).to receive(:refresh_device_ordering_status!).and_call_original
        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => school.computacenter_reference, 'capAmount' => '12' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => sibling_schools.first.computacenter_reference, 'capAmount' => '4' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => sibling_schools.last.computacenter_reference, 'capAmount' => '4' },
          ],
        ]

        school.std_device_allocation.update!(devices_ordered: 9)

        expect(school).to have_received(:refresh_device_ordering_status!)
        expect_school_to_be_in_rb(school_id: school.id,
                                  rb_id: rb.id,
                                  vcap: true,
                                  laptop_allocation: 15,
                                  laptop_cap: 14,
                                  laptops_ordered: 11,
                                  router_allocation: 0,
                                  router_cap: 0,
                                  routers_ordered: 0,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
        sibling_schools.each do |school|
          expect_school_to_be_in_rb(school_id: school.id,
                                    rb_id: rb.id,
                                    vcap: true,
                                    laptop_allocation: 15,
                                    laptop_cap: 14,
                                    laptops_ordered: 11,
                                    router_allocation: 0,
                                    router_cap: 0,
                                    routers_ordered: 0,
                                    centrally_managed: true,
                                    manages_orders: false,
                                    requests: requests)
        end
      end

      context 'when the pool has not enough devices available' do
        let(:alert) { 'Unable to reclaim all of the allocation in the vcap to cover the over-order' }
        let(:sentry_context_key) { 'AllocationOverOrderService#reclaim_allocation_across_virtual_cap_pool' }
        let(:sentry_context_value) do
          {
            vcap_pool_id: rb.std_device_pool.id,
            remaining_over_ordered_quantity: non_allocated_but_ordered_devices,
          }
        end
        let(:sentry_scope) { instance_spy(Sentry::Scope, set_context: :great) }
        let(:non_allocated_but_ordered_devices) { 5 }

        before do
          allow(Sentry).to receive(:capture_message)
          allow(Sentry).to receive(:with_scope).and_yield(sentry_scope)
        end

        it 'get the extra devices ordered from the devices available in the pool and alert Sentry' do
          allow(school).to receive(:refresh_device_ordering_status!).and_call_original
          requests = [
            [
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => school.computacenter_reference, 'capAmount' => '18' },
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => sibling_schools.first.computacenter_reference, 'capAmount' => '1' },
              { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => sibling_schools.last.computacenter_reference, 'capAmount' => '1' },
            ],
          ]

          school.std_device_allocation.update!(devices_ordered: 18)

          expect(school).to have_received(:refresh_device_ordering_status!)
          expect_school_to_be_in_rb(school_id: school.id,
                                    rb_id: rb.id,
                                    vcap: true,
                                    laptop_allocation: 20,
                                    laptop_cap: 20,
                                    laptops_ordered: 20,
                                    router_allocation: 0,
                                    router_cap: 0,
                                    routers_ordered: 0,
                                    centrally_managed: true,
                                    manages_orders: false,
                                    requests: requests)
          sibling_schools.each do |school|
            expect_school_to_be_in_rb(school_id: school.id,
                                      rb_id: rb.id,
                                      vcap: true,
                                      laptop_allocation: 20,
                                      laptop_cap: 20,
                                      laptops_ordered: 20,
                                      router_allocation: 0,
                                      router_cap: 0,
                                      routers_ordered: 0,
                                      centrally_managed: true,
                                      manages_orders: false,
                                      requests: requests)
          end
          expect(Sentry).to have_received(:capture_message).with(alert)
          expect(sentry_scope).to have_received(:set_context).with(sentry_context_key, sentry_context_value)
        end
      end
    end

    context 'when the school is not in virtual cap pool' do
      let(:school) do
        create(:school,
               :centrally_managed,
               :with_std_device_allocation,
               responsible_body: rb,
               laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1)
      end

      it 'adjust cap and allocation values to match devices ordered' do
        allow(school).to receive(:refresh_device_ordering_status!).and_call_original
        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => school.computacenter_reference, 'capAmount' => '9' },
          ],
        ]

        school.std_device_allocation.update!(devices_ordered: 9)

        expect(school).to have_received(:refresh_device_ordering_status!)
        expect_school_to_be_in_rb(school_id: school.id,
                                  rb_id: rb.id,
                                  vcap: false,
                                  laptop_allocation: 9,
                                  laptop_cap: 9,
                                  laptops_ordered: 9,
                                  router_allocation: 0,
                                  router_cap: 0,
                                  routers_ordered: 0,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
      end
    end
  end
end
