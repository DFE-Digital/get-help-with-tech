require 'rails_helper'

RSpec.describe Support::School::ChangeResponsibleBodyForm, type: :model do
  it { is_expected.to validate_presence_of(:school) }
  it { is_expected.to validate_presence_of(:responsible_body) }

  describe '#responsible_body_id' do
    let(:school) { build_stubbed(:school) }
    let(:responsible_body_id) { school.responsible_body_id.next }

    context 'when a new responsible_body_id is given at initialization time' do
      subject(:form) { described_class.new(school: school, responsible_body_id: responsible_body_id) }

      it 'return the new responsible_body_id' do
        expect(form.responsible_body_id).to eq(responsible_body_id)
      end
    end

    context 'when a new responsible_body_id is not given at initialization time' do
      subject(:form) { described_class.new(school: school) }

      it 'return the given school responsible_body_id' do
        expect(form.responsible_body_id).to eq(school.responsible_body_id)
      end
    end
  end

  describe '#responsible_body' do
    let(:school) { create(:school) }

    context 'when a new responsible_body_id is given at initialization time' do
      let(:new_responsible_body) { create(:trust) }

      subject(:form) { described_class.new(school: school, responsible_body_id: new_responsible_body.id) }

      it 'return the new responsible_body' do
        expect(form.responsible_body).to eq(new_responsible_body)
      end
    end

    context 'when a new responsible_body_id is not given at initialization time' do
      subject(:form) { described_class.new(school: school) }

      it 'return the given school responsible_body' do
        expect(form.responsible_body).to eq(school.responsible_body)
      end
    end
  end

  describe '#responsible_body_options' do
    subject(:form) { described_class.new }

    let!(:open_rbs) { create_list(:trust, 2) }

    before do
      create_list(:trust, 2, status: :closed)
    end

    it 'return a list of objects from the existing open responsible bodies including their id and name' do
      expect(form.responsible_body_options.map(&:id)).to match_array(open_rbs.map(&:id))
      expect(form.responsible_body_options.map(&:name)).to match_array(open_rbs.map(&:name))
    end
  end

  describe '#save' do
    before { stub_computacenter_outgoing_api_calls }

    context 'when the form is not valid' do
      let(:school) { create(:school) }
      let(:responsible_body_id) { school.responsible_body_id }

      subject(:form) { described_class.new(school: school, responsible_body_id: responsible_body_id.next) }

      it 'return false' do
        expect(form.save).to be_falsey
      end

      it 'do not change the school responsible body' do
        expect(school.reload.responsible_body_id).to eq(responsible_body_id)
      end
    end

    context 'when the form is valid' do
      let(:school) { create(:school, :with_preorder_information) }
      let(:new_rb) { create(:trust) }

      let!(:initial_rb_id) { school.responsible_body_id }

      subject(:form) { described_class.new(school: school, responsible_body_id: new_rb.id) }

      before { stub_computacenter_outgoing_api_calls }

      it 'return true' do
        expect(form.save).to be_truthy
      end

      it 'change the school responsible body' do
        expect { form.save }.to change { school.reload.responsible_body_id }.from(initial_rb_id).to(new_rb.id)
      end
    end

    context 'move school that manages orders to centrally managed no vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :manages_centrally, computacenter_reference: '2000', vcap_feature_flag: false) }

      let!(:moving_school) do
        create(:school,
               :manages_orders,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school that manages orders to centrally managed vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :manages_centrally, computacenter_reference: '2000', vcap_feature_flag: true) }

      let!(:moving_school) do
        create(:school,
               :manages_orders,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school that manages orders to school manages no vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :devolves_management, computacenter_reference: '2000', vcap_feature_flag: false) }

      let!(:moving_school) do
        create(:school,
               :manages_orders,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school that manages orders to school manages vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :devolves_management, computacenter_reference: '2000', vcap_feature_flag: true) }

      let!(:moving_school) do
        create(:school,
               :manages_orders,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: false,
                                  manages_orders: true,
                                  requests: requests)
      end
    end

    context 'move school centrally managed no vcap to centrally managed no vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: false) }
      let(:rb_b) { create(:local_authority, :manages_centrally, computacenter_reference: '2000', vcap_feature_flag: false) }

      let!(:moving_school) do
        create(:school,
               :centrally_managed,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
      end
    end

    context 'move school centrally managed no vcap to centrally managed vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: false) }
      let(:rb_b) { create(:local_authority, :manages_centrally, computacenter_reference: '2000', vcap_feature_flag: true) }

      let!(:moving_school) do
        create(:school,
               :centrally_managed,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
      end
    end

    context 'move school centrally managed no vcap to school manages vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: false) }
      let(:rb_b) { create(:local_authority, :devolves_management, computacenter_reference: '2000', vcap_feature_flag: true) }

      let!(:moving_school) do
        create(:school,
               :centrally_managed,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).once
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)
      end
    end

    context 'move school centrally managed vcap to centrally managed no vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :manages_centrally, computacenter_reference: '2000', vcap_feature_flag: false) }

      let!(:moving_school) do
        create(:school,
               :centrally_managed,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        rb_a.calculate_vcaps!
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'AAA', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'AAA', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).at_least(1).times
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: false,
                                  laptop_allocation: 5,
                                  laptop_cap: 1,
                                  laptops_ordered: 1,
                                  router_allocation: 5,
                                  router_cap: 1,
                                  routers_ordered: 1,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)

        expect_vcap_to_be(rb_id: rb_a.id,
                          laptop_allocation: 5,
                          laptop_cap: 1,
                          laptops_ordered: 1,
                          router_allocation: 5,
                          router_cap: 1,
                          routers_ordered: 1)
      end
    end

    context 'move school centrally managed vcap to centrally managed vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :manages_centrally, computacenter_reference: '2000', vcap_feature_flag: true) }

      let!(:moving_school) do
        create(:school,
               :centrally_managed,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        rb_a.calculate_vcaps!
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'AAA', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'AAA', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).at_least(1).times
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)

        expect_vcap_to_be(rb_id: rb_a.id,
                          laptop_allocation: 5,
                          laptop_cap: 1,
                          laptops_ordered: 1,
                          router_allocation: 5,
                          router_cap: 1,
                          routers_ordered: 1)
      end
    end

    context 'move school centrally managed vcap to school manages vcap responsible body' do
      subject(:form) { described_class.new(school: moving_school, responsible_body_id: rb_b.id) }

      let(:rb_a) { create(:local_authority, :manages_centrally, computacenter_reference: '1000', vcap_feature_flag: true) }
      let(:rb_b) { create(:local_authority, :devolves_management, computacenter_reference: '2000', vcap_feature_flag: true) }

      let!(:moving_school) do
        create(:school,
               :centrally_managed,
               computacenter_reference: 'MOVING',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])
      end

      before do
        allow(moving_school).to receive(:refresh_preorder_status!).and_call_original

        create(:school,
               :centrally_managed,
               computacenter_reference: 'AAA',
               responsible_body: rb_a,
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        create(:school,
               :centrally_managed,
               responsible_body: rb_b,
               computacenter_reference: 'BBB',
               laptops: [5, 4, 1],
               routers: [5, 4, 1])

        rb_a.calculate_vcaps!
      end

      it 'moves school to new rb' do
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_a.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: false)

        requests = [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'AAA', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'AAA', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'MOVING', 'capAmount' => '1' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => 'BBB', 'capAmount' => '1' },
          ],
        ]

        expect(form.save).to be_truthy

        expect(moving_school).to have_received(:refresh_preorder_status!).at_least(1).times
        expect_school_to_be_in_rb(school_id: moving_school.id,
                                  rb_id: rb_b.id,
                                  vcap: true,
                                  laptop_allocation: 10,
                                  laptop_cap: 2,
                                  laptops_ordered: 2,
                                  router_allocation: 10,
                                  router_cap: 2,
                                  routers_ordered: 2,
                                  centrally_managed: true,
                                  manages_orders: false,
                                  requests: requests)

        expect_vcap_to_be(rb_id: rb_a.id,
                          laptop_allocation: 5,
                          laptop_cap: 1,
                          laptops_ordered: 1,
                          router_allocation: 5,
                          router_cap: 1,
                          routers_ordered: 1)
      end
    end
  end
end
