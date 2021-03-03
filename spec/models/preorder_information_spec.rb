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

      subject { preorder_information.infer_status }

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

      subject { preorder_information.infer_status }

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

      subject { preorder_information.infer_status }

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
        let(:allocation) { create(:school_device_allocation, :with_std_allocation, :fully_ordered) }

        it { is_expected.to eq('ordered') }
      end

      context 'when some devices have been ordered' do
        let(:allocation) { create(:school_device_allocation, :with_coms_allocation, devices_ordered: 5) }

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
               who_will_order_devices: 'school').infer_status
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
        let(:allocation) { build(:school_device_allocation, :fully_ordered, device_type: 'std_device') }

        it { is_expected.to eq('ordered') }
      end

      context 'when there are no devices available to order' do
        let(:allocation) { create(:school_device_allocation) }

        it { is_expected.to eq('school_ready') }
      end
    end
  end

  describe 'changes to related status information' do
    let(:trust) { create(:trust) }
    let(:school) { create(:school, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: trust) }

    subject(:preorder_info) { create(:preorder_information, school: school) }

    context 'when school will order devices' do
      let(:user) { create(:user) }

      before do
        trust.update!(who_will_order_devices: 'school')
        preorder_info.update!(who_will_order_devices: 'school', will_need_chromebooks: nil)
      end

      it 'responds to setting a contact' do
        expect(preorder_info.status).to eq('needs_contact')
        school.contacts.create!(email_address: 'contact@school.com',
                                full_name: 'Mary Smith',
                                role: 'headteacher')
        preorder_info.update!(school_contact: school.contacts.first)
        expect(preorder_info.status).to eq('school_will_be_contacted')
      end

      it 'responds to removing the contact' do
        school.contacts.create!(email_address: 'contact@school.com',
                                full_name: 'Mary Smith',
                                role: 'headteacher')
        preorder_info.update!(school_contact: school.contacts.first)
        expect(preorder_info.status).to eq('school_will_be_contacted')

        preorder_info.update!(school_contact: nil)
        expect(preorder_info.status).to eq('needs_contact')
      end

      it 'responds to adding users' do
        expect(preorder_info.status).to eq('needs_contact')
        school.users << user
        expect(preorder_info.status).to eq('school_contacted')
      end

      it 'responds to removing users' do
        school.users << user
        expect(preorder_info.status).to eq('school_contacted')
        school.users.destroy(user)
        expect(preorder_info.status).to eq('needs_contact')
      end

      it 'responds to completing chromebook information' do
        school.users << user
        expect(preorder_info.status).to eq('school_contacted')
        preorder_info.update!(will_need_chromebooks: 'no')
        expect(preorder_info.status).to eq('school_ready')
      end

      it 'responds to changing the device allocation' do
        school.users << user
        preorder_info.update!(will_need_chromebooks: 'no')
        expect(preorder_info.status).to eq('school_ready')
        school.std_device_allocation.update!(devices_ordered: 2)
        school.device_allocations.reload
        preorder_info.refresh_status!
        expect(preorder_info.status).to eq('ordered')
      end

      it 'responds to changing the order_state of the school' do
        school.users << user
        school.std_device_allocation.update!(cap: 10, allocation: 10, devices_ordered: 0)
        preorder_info.update!(will_need_chromebooks: 'no')
        expect(preorder_info.status).to eq('school_ready')
        school.can_order!
        expect(preorder_info.status).to eq('school_can_order')
      end
    end

    context 'when chromebook information complete' do
      before do
        trust.update!(who_will_order_devices: 'responsible_body')
        school.std_device_allocation.update!(devices_ordered: 0, cap: 4, allocation: 10)
        preorder_info.update!(who_will_order_devices: 'responsible_body',
                              will_need_chromebooks: 'yes',
                              school_or_rb_domain: 'domain.com',
                              recovery_email_address: 'school@gmail.com')

        preorder_info.refresh_status!
      end

      it 'responds to changing the device allocation' do
        expect(preorder_info.status).to eq('ready')
        school.std_device_allocation.update!(devices_ordered: 2)
        school.device_allocations.reload
        preorder_info.refresh_status!
        expect(preorder_info.status).to eq('ordered')
      end

      it 'responds to changing the order_state of the school' do
        expect(preorder_info.status).to eq('ready')
        school.can_order!
        expect(preorder_info.status).to eq('rb_can_order')
      end
    end
  end
end
