require 'rails_helper'

RSpec.describe PreorderInformation, type: :model do
  it { is_expected.to be_versioned }

  describe 'status' do
    context 'when the school orders devices and the school contact is missing' do
      subject do
        build(:preorder_information,
              who_will_order_devices: :school,
              school_contact: nil,
              school_contacted_at: nil).infer_status
      end

      it { is_expected.to eq('needs_contact') }
    end

    context "when the school orders devices, the school contact is present but hasn't been contacted yet" do
      subject do
        build(:preorder_information,
              who_will_order_devices: :school,
              school_contact: build(:school_contact),
              school_contacted_at: nil).infer_status
      end

      it { is_expected.to eq('school_will_be_contacted') }
    end

    context "when the school orders devices, it's been contacted but hasn't logged in to input the Chromebook details" do
      let(:preorder_information) do
        create(:preorder_information,
               who_will_order_devices: :school,
               school_contact: build(:school_contact),
               will_need_chromebooks: nil)
      end

      subject { preorder_information.reload.infer_status }

      before do
        create(:school_user, school: preorder_information.school)
      end

      it { is_expected.to eq('school_contacted') }
    end

    context "when the school orders devices, it has logged in and doesn't plan to order Chromebooks" do
      let(:preorder_information) do
        create(:preorder_information,
               :does_not_need_chromebooks,
               who_will_order_devices: :school)
      end

      subject { preorder_information.reload.infer_status }

      before do
        create(:school_user, school: preorder_information.school)
      end

      it { is_expected.to eq('school_ready') }
    end

    context 'when the school orders devices, it has logged in and plans to order Chromebooks' do
      let(:preorder_information) do
        create(:preorder_information,
               :needs_chromebooks,
               who_will_order_devices: :school)
      end

      subject { preorder_information.reload.infer_status }

      before do
        create(:school_user, school: preorder_information.school)
      end

      it { is_expected.to eq('school_ready') }
    end

    context 'when the orders are placed centrally and the responsible body has not provided Chromebook details' do
      subject do
        build(:preorder_information,
              who_will_order_devices: :responsible_body,
              will_need_chromebooks: nil).infer_status
      end

      it { is_expected.to eq('needs_info') }
    end

    context "when the orders are placed centrally and the responsible body doesn't plan to order Chromebooks" do
      subject do
        build(:preorder_information,
              :does_not_need_chromebooks,
              who_will_order_devices: :responsible_body).infer_status
      end

      it { is_expected.to eq('ready') }
    end

    context 'when the orders are placed centrally and the school has logged in and plans to order Chromebooks' do
      subject do
        build(:preorder_information,
              :needs_chromebooks,
              who_will_order_devices: :responsible_body).infer_status
      end

      it { is_expected.to eq('ready') }
    end

    context 'when rb orders and status is ready' do
      let(:order_state) { 'can_order' }
      let(:school) { create(:school, std_device_allocation: allocation, order_state: order_state) }

      subject do
        create(:preorder_information,
               :needs_chromebooks,
               school: school,
               who_will_order_devices: :responsible_body).infer_status
      end

      context 'when there are devices available to order' do
        let(:allocation) { create(:school_device_allocation, :with_orderable_devices) }

        it { is_expected.to eq('rb_can_order') }
      end

      context 'when there are devices available to order but school cannot order' do
        let(:order_state) { 'cannot_order' }
        let(:allocation) { create(:school_device_allocation, :with_orderable_devices) }

        it { is_expected.to eq('ready') }
      end

      context 'when all devices have been ordered' do
        let(:allocation) { create(:school_device_allocation, :fully_ordered) }

        it { is_expected.to eq('ordered') }
      end

      context 'when there are no devices available to order' do
        let(:allocation) { create(:school_device_allocation) }

        it { is_expected.to eq('ready') }
      end
    end

    context 'when school orders and status is school ready' do
      let(:user) { create(:school_user) }
      let(:order_state) { 'can_order' }
      let(:school) { create(:school, std_device_allocation: allocation, users: [user], order_state: order_state) }

      subject do
        create(:preorder_information,
               :needs_chromebooks,
               school: school,
               who_will_order_devices: 'school').reload.infer_status
      end

      context 'when there are devices available to order' do
        let(:allocation) { create(:school_device_allocation, :with_orderable_devices) }

        it { is_expected.to eq('school_can_order') }
      end

      context 'when there are devices available to order but school cannot order' do
        let(:order_state) { 'cannot_order' }
        let(:allocation) { create(:school_device_allocation, :with_orderable_devices) }

        it { is_expected.to eq('school_ready') }
      end

      context 'when all devices have been ordered' do
        let(:allocation) { create(:school_device_allocation, :fully_ordered) }

        it { is_expected.to eq('ordered') }
      end

      context 'when there are no devices available to order' do
        let(:allocation) { create(:school_device_allocation) }

        it { is_expected.to eq('school_ready') }
      end
    end
  end
end
