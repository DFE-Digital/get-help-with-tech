require 'rails_helper'

RSpec.describe ChangeSchoolResponsibleBodyService, type: :model do
  let(:rb_a_pool_active) { true }
  let(:rb_b_pool_active) { false }
  let(:who_manages_rb_a) { :manages_centrally }
  let(:who_manages_rb_b) { :manages_centrally }
  let(:who_manages_moving_school) { :manages_orders }

  let(:service) { described_class.new(moving_school, rb_b) }

  describe '#call' do
    let(:rb_a) { create(:local_authority, who_manages_rb_a, computacenter_reference: '1000', vcap_feature_flag: rb_a_pool_active) }
    let(:rb_b) { create(:local_authority, who_manages_rb_b, computacenter_reference: '2000', vcap_feature_flag: rb_b_pool_active) }
    let(:service) { described_class.new(moving_school, rb_b) }

    let!(:school_a) do
      create(:school,
             :centrally_managed,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             computacenter_reference: 'AAA',
             responsible_body: rb_a,
             laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    let!(:school_b) do
      create(:school,
             :centrally_managed,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             responsible_body: rb_b,
             computacenter_reference: 'BBB',
             laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    let!(:moving_school) do
      create(:school,
             who_manages_moving_school,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             computacenter_reference: 'MOVING',
             responsible_body: rb_a,
             laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 1,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    before do
      stub_computacenter_outgoing_api_calls
      AddSchoolToVirtualCapPoolService.new(school_a).call
      AddSchoolToVirtualCapPoolService.new(school_b).call
      rb_a.reload
      rb_b.reload
      allow(moving_school).to receive(:refresh_device_ordering_status!).and_call_original
    end

    context 'when the school cannot be updated for some reason' do
      let(:moving_school) { create(:school, :with_preorder_information) }

      it 'do not change the school responsible body' do
        expect {
          moving_school.name = nil
          service.call
        }.not_to(change { moving_school.reload.responsible_body_id })
      end

      it 'do not change the school status' do
        expect {
          moving_school.name = nil
          service.call
        }.not_to(change { moving_school.reload.status })
      end
    end

    context 'when the school status cannot be refreshed for some reason' do
      let(:moving_school) { create(:school) }

      it 'do not change the school responsible body' do
        expect {
          allow(moving_school).to receive(:refresh_device_ordering_status!).and_raise
          service.call
        }.not_to(change { moving_school.reload.responsible_body_id })
      end

      it 'do not change the school status' do
        expect {
          allow(moving_school).to receive(:refresh_device_ordering_status!).and_raise
          service.call
        }.not_to(change { moving_school.reload.status })
      end
    end

    context 'move school that manages orders to centrally managed no vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { false }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :manages_centrally }
      let(:who_manages_moving_school) { :manages_orders }

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school that manages orders to centrally managed vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { true }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :manages_centrally }
      let(:who_manages_moving_school) { :manages_orders }

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school that manages orders to school manages no vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { false }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :devolves_management }
      let(:who_manages_moving_school) { :manages_orders }

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school that manages orders to school manages vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { true }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :devolves_management }
      let(:who_manages_moving_school) { :manages_orders }

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school centrally managed no vcap to centrally managed no vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { false }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :manages_centrally }
      let(:who_manages_moving_school) { :centrally_managed }

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
      end
    end

    context 'move school centrally managed no vcap to centrally managed vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { true }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :manages_centrally }
      let(:who_manages_moving_school) { :centrally_managed }

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'BBB', 'capAmount' => '7' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '7' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'BBB', 'capAmount' => '7' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '7' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 8,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 8,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
      end
    end

    context 'move school centrally managed vcap to centrally managed no vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { false }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :manages_centrally }
      let(:who_manages_moving_school) { :centrally_managed }

      before do
        AddSchoolToVirtualCapPoolService.new(moving_school).call
        rb_b.reload
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 8,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 8,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '4' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'AAA', 'capAmount' => '4' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'AAA', 'capAmount' => '4' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).at_least(1).times
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 4,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 4,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)

        expect_vcap_to_be(rb_id: rb_a.id,
                          laptop_allocation: 5,
                          laptop_cap: 4,
                          laptops_ordered: 1,
                          router_allocation: 5,
                          router_cap: 4,
                          routers_ordered: 1)
      end
    end

    context 'move school centrally managed vcap to centrally managed vcap responsible body' do
      let(:rb_a_pool_active) { true }
      let(:rb_b_pool_active) { true }
      let(:who_manages_rb_a) { :manages_centrally }
      let(:who_manages_rb_b) { :manages_centrally }
      let(:who_manages_moving_school) { :centrally_managed }

      before do
        AddSchoolToVirtualCapPoolService.new(moving_school).call
        rb_a.reload
        rb_b.reload
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 8,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 8,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'AAA', 'capAmount' => '4' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'AAA', 'capAmount' => '4' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '7' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'BBB', 'capAmount' => '7' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '7' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'BBB', 'capAmount' => '7' },
          ],
        ]

        service.call

        expect(moving_school).to have_received(:refresh_device_ordering_status!).at_least(1).times
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 8,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 8,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)

        expect_vcap_to_be(rb_id: rb_a.id,
                          laptop_allocation: 5,
                          laptop_cap: 4,
                          laptops_ordered: 1,
                          router_allocation: 5,
                          router_cap: 4,
                          routers_ordered: 1)
      end
    end
  end
end
