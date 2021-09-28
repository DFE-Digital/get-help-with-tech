require 'rails_helper'

RSpec.describe Support::Schools::Devices::OrderStatusController do
  let(:support_user) { create(:support_user) }
  let(:user) { support_user }

  before do
    sign_in_as user
  end

  describe '#edit' do
    let(:school) do
      create(:school,
             :with_std_device_allocation_partially_ordered,
             :with_coms_device_allocation_partially_ordered)
    end

    let(:edition_values) do
      {
        order_state: 'can_order_for_specific_circumstances',
        laptop_cap: '1',
        router_cap: '1',
      }
    end

    let(:params) do
      {
        school_urn: school.urn,
        support_enable_orders_form: edition_values,
      }
    end

    before { get :edit, params: params }

    it 'responds successfully' do
      expect(response).to be_successful
    end

    context 'when given values to edit' do
      it 'assigns a form with the given order_state, laptop_cap and router_cap values' do
        expect(assigns[:form].school.urn).to eq(school.urn)
        expect(assigns[:form].order_state).to eq('can_order_for_specific_circumstances')
        expect(assigns[:form].laptop_cap).to eq(1)
        expect(assigns[:form].router_cap).to eq(1)
      end
    end

    context 'when given no values to edit' do
      let(:edition_values) { {} }

      it 'assigns a form with the default values from the school' do
        expect(assigns[:form].school.urn).to eq(school.urn)
        expect(assigns[:form].order_state).to eq(school.order_state)
        expect(assigns[:form].laptop_cap).to eq(school.laptop_cap)
        expect(assigns[:form].router_cap).to eq(school.router_cap)
      end
    end
  end

  describe '#update' do
    let(:confirm) { true }
    let(:order_state) { 'can_order_for_specific_circumstances' }
    let(:laptop_cap) { '35' }
    let(:router_cap) { '3' }
    let(:who_manages) { :centrally_managed }

    let(:params) do
      {
        confirm: confirm,
        school_urn: school.urn,
        support_enable_orders_form: {
          order_state: order_state,
          laptop_cap: laptop_cap,
          router_cap: router_cap,
        },
      }
    end

    let(:rb) do
      create(:local_authority,
             :manages_centrally,
             :vcap_feature_flag,
             computacenter_reference: '1000')
    end

    let!(:school) do
      create(:school,
             who_manages,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             computacenter_reference: '11',
             responsible_body: rb,
             laptop_allocation: 50, laptop_cap: 40, laptops_ordered: 10,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    let!(:school2) do
      create(:school,
             who_manages,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             responsible_body: rb,
             computacenter_reference: '12',
             laptop_allocation: 50, laptop_cap: 40, laptops_ordered: 10,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    before do
      stub_computacenter_outgoing_api_calls
    end

    context 'when the values assigned are not valid' do
      let(:laptop_cap) { '5000' }

      it 'display the edit view' do
        patch :update, params: params

        expect(flash[:success]).to be_blank
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the change is not confirmed' do
      let(:confirm) { nil }

      it 'redirects' do
        patch :update, params: params

        expect(response).to redirect_to(support_school_confirm_enable_orders_path(urn: school.urn,
                                                                                  order_state: order_state,
                                                                                  laptop_cap: laptop_cap,
                                                                                  router_cap: router_cap))
      end
    end

    it 'redirects to the school view' do
      patch :update, params: params

      expect(response).to redirect_to(support_school_path(school.urn))
    end

    it 'sets the given order_state to the school' do
      expect {
        patch :update, params: params
      }.to change { School.find(school.id).order_state }.from('cannot_order').to(order_state)
    end

    it 'sets the given laptop cap to the school' do
      expect {
        patch :update, params: params
      }.to change { School.find(school.id).laptop_cap }.from(40).to(laptop_cap.to_i)
    end

    it 'sets the given router cap to the school' do
      expect {
        patch :update, params: params
      }.to change { School.find(school.id).router_cap }.from(4).to(router_cap.to_i)
    end

    context 'when the school is not in virtual cap pool' do
      let(:who_manages) { :manages_orders }
      let(:requests) do
        [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '35' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '3' },
          ],
        ]
      end

      it 'update school caps on Computacenter' do
        patch :update, params: params

        expect_to_have_sent_caps_to_computacenter(requests)
      end

      it 'notify Computacenter of laptops cap change by email' do
        expect { patch :update, params: params }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
                .with(params: { school: school, new_cap_value: 35 }, args: []).once
      end

      it 'notify Computacenter of routers cap change by email' do
        expect { patch :update, params: params }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_comms_cap_change)
                .with(params: { school: school, new_cap_value: 3 }, args: []).once
      end

      it "notify the school's organizational users" do
        user = create(:user, :relevant_to_computacenter, school: school)

        expect { patch :update, params: params }
          .to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed)
                .with(params: { school: school, user: user }, args: []).once
      end

      it "notify support if no school's organizational users" do
        expect { patch :update, params: params }
          .to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
                .with(params: { school: school }, args: []).once
      end

      it 'notify Computacenter of school can order by email' do
        expect { patch :update, params: params }
          .to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order)
                .with(params: { school: school, new_cap_value: 35 }, args: []).once
      end
    end

    context 'when the school is in virtual cap pool' do
      let(:who_manages) { :centrally_managed }
      let(:requests) do
        [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '65' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '65' },
          ],
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '6' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '12', 'capAmount' => '6' },
          ],
        ]
      end

      before do
        AddSchoolToVirtualCapPoolService.new(school).call
        AddSchoolToVirtualCapPoolService.new(school2).call
      end

      it 'update school caps on Computacenter' do
        patch :update, params: params

        expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
      end

      it 'do not notify Computacenter of laptops cap change by email' do
        expect { patch :update, params: params }
          .not_to have_enqueued_mail(ComputacenterMailer)
      end

      it "do not notify support if no school's organizational users" do
        expect { patch :update, params: params }
          .not_to have_enqueued_mail(CanOrderDevicesMailer)
      end
    end
  end

  describe '#confirm' do
    let(:school) do
      create(:school,
             :with_std_device_allocation_partially_ordered,
             :with_coms_device_allocation_partially_ordered)
    end

    let(:edition_values) do
      {
        order_state: 'cannot_order',
        laptop_cap: '10',
        router_cap: '4',
      }
    end

    let(:params) { edition_values.merge(school_urn: school.urn) }

    before { get :confirm, params: params }

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'assigns a form with the given order_state, laptop_cap and router_cap values' do
      expect(assigns[:form].school.urn).to eq(school.urn)
      expect(assigns[:form].order_state).to eq('cannot_order')
      expect(assigns[:form].laptop_cap).to eq(10)
      expect(assigns[:form].router_cap).to eq(4)
    end

    it 'assigns laptop and router allocations vars from the school values' do
      expect(assigns[:laptop_allocation]).to eq(school.laptop_allocation)
      expect(assigns[:router_allocation]).to eq(school.router_allocation)
    end

    it 'renders the confirm template' do
      expect(response).to render_template(:confirm)
    end
  end

  describe '#collect_urns_to_allow_many_schools_to_order' do
    let(:school) do
      create(:school,
             :with_std_device_allocation_partially_ordered,
             :with_coms_device_allocation_partially_ordered)
    end

    before { get :collect_urns_to_allow_many_schools_to_order }

    context 'when the user is not support' do
      let(:user) { create(:user) }

      it 'forbid' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'assigns an empty Support::BulkAllocationForm' do
      expect(assigns[:form].upload).to be_blank
      expect(assigns[:form].send_notification).to be_blank
    end

    it 'renders the collect_urns_to_allow_many_schools_to_order template' do
      expect(response).to render_template(:collect_urns_to_allow_many_schools_to_order)
    end
  end

  describe '#allow_ordering_for_many_schools' do
    let(:file) { fixture_file_upload('allocation_upload.csv', 'text/csv') }
    let(:params) do
      {
        support_bulk_allocation_form: {
          upload: file,
          send_notification: 'true',
        },
      }
    end

    context 'when the user is not support' do
      let(:user) { create(:user) }

      before { put :allow_ordering_for_many_schools, params: params }

      it 'forbid' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    it 'enqueue an AllocationJob per allocation contained in the given file' do
      expect {
        put :allow_ordering_for_many_schools, params: params
      }.to have_enqueued_job(AllocationJob).twice
    end

    it 'redirects to the bulk job page' do
      put :allow_ordering_for_many_schools, params: params

      expect(response).to redirect_to(support_allocation_batch_job_path(assigns[:form].batch_id))
    end
  end
end
