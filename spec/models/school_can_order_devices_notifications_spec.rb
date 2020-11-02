require 'rails_helper'

RSpec.describe SchoolCanOrderDevicesNotifications, with_feature_flags: { slack_notifications: 'active' } do
  let(:order_state) { 'cannot_order' }
  let(:school) do
    create(:school,
           :with_std_device_allocation,
           :with_preorder_information,
           order_state: order_state)
  end

  subject(:service) do
    described_class.new(school: school)
  end

  describe '#call' do
    context 'when school which is ready changes from cannot_order to can lockdown order' do
      before do
        school.update!(order_state: 'can_order')
        school.std_device_allocation.update!(cap: school.std_device_allocation.allocation)
        school.preorder_information.update!(who_will_order_devices: 'school', status: 'school_can_order', will_need_chromebooks: 'no')
      end

      context 'user has confirmed techsource account' do
        let(:user) do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'notifies the user' do
          user

          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order', 'deliver_now', params: { user: user, school: school }, args: [])
        end

        it 'puts a message in Slack' do
          user

          expect {
            service.call
          }.to have_enqueued_job.on_queue('slack_messages').with(
            username: 'dfe_ghwt_slack_bot',
            channel: 'get-help-with-tech-test',
            text: "[User can order event] We emailed a user to tell them that they can place orders for #{school.name}",
            mrkdwn: true,
          )
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

    context 'when a school that is ready changes status from specfic circumstances to lockdown' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order_for_specific_circumstances') }

      subject(:service) { described_class.new(school: school) }

      before do
        school.update!(order_state: 'can_order')
        service
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

      subject(:service) { described_class.new(school: school) }

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
      subject(:service) do
        described_class.new(school: school)
      end

      let(:user) { create(:school_user, school: school) }

      before do
        school.update!(order_state: 'can_order')
        school.std_device_allocation.update!(cap: school.std_device_allocation.allocation)
        school.preorder_information.update!(who_will_order_devices: 'school', status: 'needs_info')
      end

      it 'notifies the ordering organisations user' do
        user

        expect {
          service.call
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'user_can_order_but_action_needed', 'deliver_now', params: { user: user, school: school }, args: [])
      end

      context 'when the user has a techsource account' do
        before do
          user.update!(techsource_account_confirmed_at: 1.second.ago,
                       orders_devices: true)
        end

        it 'puts a message in Slack' do
          expect {
            service.call
          }.to have_enqueued_job.on_queue('slack_messages').with(
            username: 'dfe_ghwt_slack_bot',
            channel: 'get-help-with-tech-test',
            text: "[User can order event] We emailed a user to tell them that action is needed before #{school.name} can place orders",
            mrkdwn: true,
          )
        end
      end
    end

    context 'when a school that is not ready changes status from specfic circumstances to lockdown' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order_for_specific_circumstances') }
      let(:user) { create(:school_user, school: school) }

      subject(:service) { described_class.new(school: school) }

      before do
        school.update!(order_state: 'can_order')
        school.preorder_information.needs_info!
        service
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

      subject(:service) { described_class.new(school: school) }

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
      let(:preorder) { create(:preorder_information, :school_will_order, status: 'needs_contact') }
      let(:school) { create(:school, preorder_information: preorder, std_device_allocation: allocation, order_state: :can_order) }
      let(:allocation) { create(:school_device_allocation, :with_std_allocation, :with_orderable_devices) }
      let(:rb) { school.responsible_body }
      let(:user) { create(:user, responsible_body: rb) }

      before do
        user
      end

      subject(:service) { described_class.new(school: school) }

      it 'nudges RB that school needs a contact' do
        expect {
          service.call
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'nudge_rb_to_add_school_contact', 'deliver_now', params: { user: user, school: school }, args: [])
      end
    end

    context 'when the school has no stakeholders' do
      let(:order_state) { 'can_order' }

      before do
        school.std_device_allocation.update!(cap: school.std_device_allocation.allocation)
      end

      it 'notifies support that school is missing out' do
        expect {
          service.call
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'notify_support_school_can_order_but_no_one_contacted', 'deliver_now', params: { school: school }, args: [])
      end
    end
  end
end
