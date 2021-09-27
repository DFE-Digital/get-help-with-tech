require 'rails_helper'

RSpec.describe Support::Schools::Devices::AllocationController do
  let(:user) { create(:support_user) }
  let(:school) { create(:school, name: 'SchoolName', computacenter_reference: '11') }

  before do
    sign_in_as user
  end

  describe '#edit' do
    let(:device_type) {}
    let(:school) do
      create(:school,
             :centrally_managed,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             computacenter_reference: '11',
             laptop_allocation: 50, laptop_cap: 40, laptops_ordered: 10,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    before { get :edit, params: { school_urn: school.urn, device_type: device_type } }

    context 'when the user is not support' do
      let(:user) { create(:user) }

      it 'forbid' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'assigns a form for the school laptop allocation' do
      expect(assigns[:form].device_type).to eq(:laptop)
      expect(assigns[:form].raw_allocation).to eq(school.raw_laptop_allocation)
      expect(assigns[:form].raw_devices_ordered).to eq(school.raw_laptops_ordered)
      expect(assigns[:form].device_allocation).to eq(school.laptop_allocation)
      expect(assigns[:form].device_cap).to eq(school.laptop_cap)
    end

    context 'when device type is set' do
      let(:device_type) { :router }

      it 'assigns a form for that school device allocation' do
        expect(assigns[:form].device_type).to eq(:router)
        expect(assigns[:form].raw_allocation).to eq(school.raw_router_allocation)
        expect(assigns[:form].raw_devices_ordered).to eq(school.raw_routers_ordered)
        expect(assigns[:form].device_allocation).to eq(school.router_allocation)
        expect(assigns[:form].device_cap).to eq(school.router_cap)
      end
    end
  end

  describe '#update' do
    let(:allocation) { 45 }
    let(:device_type) { :laptop }

    let(:params) do
      {
        device_type: device_type,
        school_urn: school.urn,
        support_allocation_form: {
          allocation: allocation,
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
             :centrally_managed,
             :with_std_device_allocation,
             :with_coms_device_allocation,
             order_state: 'can_order',
             computacenter_reference: '11',
             responsible_body: rb,
             laptop_allocation: 50, laptop_cap: 40, laptops_ordered: 10,
             router_allocation: 5, router_cap: 4, routers_ordered: 1)
    end

    let(:requests) do
      [
        [
          { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '45' },
        ],
      ]
    end

    before do
      stub_computacenter_outgoing_api_calls
    end

    context 'when the user is not support' do
      let(:user) { create(:user) }

      before { patch :update, params: params }

      it 'forbid' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the allocation assigned is not valid' do
      let(:allocation) { '9' }

      it 'display the edit view' do
        patch :update, params: params

        expect(flash[:success]).to be_blank
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'redirects to the school view' do
      patch :update, params: params

      expect(response).to redirect_to(support_school_path(school.urn))
    end

    it 'displays successful message' do
      patch :update, params: params

      expect(flash[:success]).to eq("We’ve saved the new allocation")
    end

    it 'sets the given allocation to the school' do
      expect {
        patch :update, params: params
      }.to change { School.find(school.id).laptop_allocation }.from(50).to(allocation.to_i)
    end

    it 'adjust school laptop cap based on school order state' do
      expect { patch :update, params: params }
        .to change { school.reload.laptop_cap }.from(40).to(45)
    end

    it 'update school devices cap on Computacenter' do
      patch :update, params: params

      expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
    end

    it 'notify Computacenter of laptops cap change by email' do
      expect { patch :update, params: params }
        .to have_enqueued_mail(ComputacenterMailer, :notify_of_devices_cap_change)
              .with(params: { school: school, new_cap_value: 45 }, args: []).once
    end

    it "notify the school's organizational users" do
      user = create(:user, :relevant_to_computacenter, responsible_body: rb)

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
              .with(params: { school: school, new_cap_value: 45 }, args: []).once
    end
  end
end
