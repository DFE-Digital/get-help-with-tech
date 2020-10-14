require 'rails_helper'

RSpec.describe CanOrderDevicesNotifications do
  let(:school) do
    create(:school,
           :with_std_device_allocation,
           :with_preorder_information,
           order_state: 'cannot_order')
  end

  around do |example|
    FeatureFlag.activate(:notify_can_place_orders)
    FeatureFlag.activate(:slack_notifications)
    example.run
    FeatureFlag.deactivate(:notify_can_place_orders)
    FeatureFlag.deactivate(:slack_notifications)
  end

  describe '#call' do
    context 'when school which is ready changes from cannot_order to can lockdown order' do
      subject(:service) do
        described_class.new(school: school)
      end

      before do
        school.update!(order_state: 'can_order')
        school.std_device_allocation.update!(cap: school.std_device_allocation.allocation)
        school.preorder_information.update!(who_will_order_devices: 'school')
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
          }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'notify_user_email', 'deliver_now', params: { user: user, school: school }, args: [])
        end

        it 'puts a message in Slack' do
          user

          expect {
            service.call
          }.to have_enqueued_job.on_queue('slack_messages').with(
            username: 'dfe_ghwt_slack_bot',
            channel: 'get-help-with-tech-test',
            text: "[User can order event] A user from #{school.name} is able to place orders",
            mrkdwn: true,
          )
        end

        it 'emails computacenter' do
          expect {
            service.call
          }.to have_enqueued_job.on_queue('mailers').with('ComputacenterMailer', 'notify_of_school_can_order', 'deliver_now', params: { school: school, new_cap_value: school.std_device_allocation.cap }, args: [])
        end

        context 'when feature is deactivated' do
          around do |example|
            FeatureFlag.deactivate(:notify_can_place_orders)
            example.run
            FeatureFlag.activate(:notify_can_place_orders)
          end

          it 'does not notify the user' do
            expect {
              service.call
            }.not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'notify_user_email', 'deliver_now', params: { user: user, school: school }, args: [])
          end
        end
      end

      context 'user can order devices but yet to have techsource account' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: nil,
                 orders_devices: true)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'notify_user_email', 'deliver_now', params: { user: user, school: school }, args: [])
        end
      end

      context 'user can not order devices' do
        let!(:user) { create(:school_user, school: school, orders_devices: false) }

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer', 'notify_user_email', 'deliver_now', params: { user: user, school: school }, args: [])
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

    context 'when status change from can_order to cannot_order' do
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
        }.to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesButActionNeededMailer', 'notify_user_email', 'deliver_now', params: { user: user, school: school }, args: [])
      end

      it 'puts a message in Slack' do
        user

        expect {
          service.call
        }.to have_enqueued_job.on_queue('slack_messages').with(
          username: 'dfe_ghwt_slack_bot',
          channel: 'get-help-with-tech-test',
          text: "[User can order event] A user from #{school.name} is able to place orders",
          mrkdwn: true,
        )
      end

      context 'when feature is deactivated' do
        around do |example|
          FeatureFlag.deactivate(:notify_can_place_orders)
          example.run
          FeatureFlag.activate(:notify_can_place_orders)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_job.on_queue('mailers')
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
  end
end
