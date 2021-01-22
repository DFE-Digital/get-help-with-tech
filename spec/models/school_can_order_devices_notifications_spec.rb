require 'rails_helper'

RSpec.describe SchoolCanOrderDevicesNotifications do
  let(:order_state) { 'cannot_order' }
  let(:contact) { create(:user) }
  let(:school) { create_schools_at_status(preorder_status: 'school_can_order') }

  subject(:service) do
    described_class.new(school: school.reload)
  end

  describe '#call' do
    context 'when school which is ready changes from cannot_order to can lockdown order' do
      context 'user has confirmed techsource account' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'notifies the user' do
          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user: user, school: school }, args: [])
        end
      end

      context 'user can order devices but not read privacy policy' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: nil,
                 privacy_notice_seen_at: nil,
                 orders_devices: true)
        end

        it 'notifies the user' do
          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'nudge_user_to_read_privacy_policy', 'deliver_now', params: { user: user, school: school }, args: [])
        end
      end

      context 'user can order devices but yet to have techsource account' do
        before do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: nil,
                 orders_devices: true)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer')
        end
      end

      context 'user can not order devices' do
        before do
          create(:school_user, school: school, orders_devices: false)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer')
        end
      end
    end

    context 'when school ordering centrally in virtual cap which is ready changes from cannot_order to can_order' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
      let(:school) do
        create(:school,
               :with_std_device_allocation,
               :with_preorder_information,
               order_state: order_state,
               responsible_body: responsible_body)
      end

      before do
        school.preorder_information.update!(who_will_order_devices: 'responsible_body', will_need_chromebooks: 'no')
        school.std_device_allocation.update!(cap: school.std_device_allocation.allocation, devices_ordered: 0)
        school.update!(order_state: 'can_order')
        school.reload
      end

      context 'user has confirmed techsource account' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 responsible_body: responsible_body,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'notifies the user' do
          expect(school.preorder_information.status).to eq('rb_can_order')
          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_in_virtual_cap', 'deliver_now', params: { user: user, school: school }, args: [])
        end
      end
    end

    context 'when school in virtual college which is ready changes from cannot_order to can_order' do
      let(:responsible_body) { create(:further_education_college, :new_fe_wave) }
      let(:school) do
        create(:fe_school,
               :with_std_device_allocation,
               :with_preorder_information,
               order_state: order_state,
               responsible_body: responsible_body)
      end

      before do
        school.preorder_information.update!(who_will_order_devices: 'responsible_body', will_need_chromebooks: 'no')
        school.std_device_allocation.update!(cap: school.std_device_allocation.allocation, devices_ordered: 0)
        school.update!(order_state: 'can_order')
        school.reload
      end

      context 'user has confirmed techsource account' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 responsible_body: responsible_body,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'notifies the user' do
          expect(school.preorder_information.status).to eq('rb_can_order')
          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_in_fe_college', 'deliver_now', params: { user: user, school: school }, args: [])
        end
      end
    end

    context 'when a school that is ready changes status from specfic circumstances to lockdown' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order_for_specific_circumstances') }

      subject(:service) { described_class.new(school: school) }

      before do
        school.update!(order_state: 'can_order')
      end

      context 'user has confirmed techsource account' do
        before do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers')
        end
      end
    end

    context 'when status changes from can_order to cannot_order' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order') }

      before do
        school.update!(order_state: 'cannot_order')
      end

      context 'user has confirmed techsource account' do
        before do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers')
        end
      end
    end

    context 'when school which is not ready changes from cannot_order to can lockdown order' do
      let(:user) { school.users.first }

      before do
        school.preorder_information.update!(who_will_order_devices: 'school', will_need_chromebooks: nil)
      end

      it 'notifies the ordering organisations user' do
        expect(school.preorder_information.status).to eq('school_contacted')

        expect {
          service.call
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_but_action_needed', 'deliver_now', params: { user: user, school: school }, args: [])
      end
    end

    context 'when a school that is not ready changes status from specfic circumstances to lockdown' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order_for_specific_circumstances') }
      let(:user) { create(:school_user, school: school) }

      before do
        school.update!(order_state: 'can_order')
        school.preorder_information.needs_info!
      end

      it 'does not notify the user' do
        expect {
          service.call
        }.not_to have_enqueued_job.on_queue('mailers')
      end
    end

    context 'when status change from can_order to cannot_order' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order') }
      let(:user) { create(:school_user, school: school) }

      before do
        school.update!(order_state: 'cannot_order')
        school.preorder_information.needs_info!
      end

      it 'does not notify the user' do
        expect {
          service.call
        }.not_to have_enqueued_job.on_queue('mailers')
      end
    end

    context 'when school preorder needs contact' do
      let(:school) { create_schools_at_status(preorder_status: 'needs_contact') }
      let(:rb) { school.responsible_body }
      let!(:user) { create(:user, responsible_body: rb) }

      before do
        school.device_allocations.std_device.create!(cap: 10, devices_ordered: 0, allocation: 10)
        school.can_order!
      end

      it 'nudges RB that school needs a contact' do
        expect {
          service.call
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'nudge_rb_to_add_school_contact', 'deliver_now', params: { user: user, school: school }, args: [])
      end
    end

    context 'when the school has no stakeholders' do
      before do
        school.users.destroy_all
      end

      it 'notifies support that school is missing out' do
        expect {
          service.call
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'notify_support_school_can_order_but_no_one_contacted', 'deliver_now', params: { school: school }, args: [])
      end
    end
  end
end
