require 'rails_helper'

RSpec.describe SchoolCanOrderDevicesNotifications do
  let(:order_state) { 'cannot_order' }
  let(:contact) { create(:user) }
  let(:school) { create_schools_at_status(preorder_status: 'school_can_order') }

  subject(:service) do
    described_class.new(school: school.reload)
  end

  describe '#call' do
    before { stub_computacenter_outgoing_api_calls }

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
          }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order).with(params: { user: user, school: school }, args: [])
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
          }.to have_enqueued_mail(CanOrderDevicesMailer, :nudge_user_to_read_privacy_policy).with(params: { user: user, school: school }, args: [])
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
          }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end
      end

      context 'user can not order devices' do
        before do
          create(:school_user, school: school, orders_devices: false)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_mail(CanOrderDevicesMailer)
        end
      end

      context 'school has opted out but would have received notification' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        before do
          school.update(opted_out_of_comms_at: 1.day.ago)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order).with(params: { user: user, school: school }, args: [])
        end
      end
    end

    context 'when school ordering centrally in virtual cap which is ready changes from cannot_order to can_order' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
      let(:school) do
        create(:school,
               :centrally_managed,
               order_state: order_state,
               responsible_body: responsible_body,
               laptops: [1, 0, 0])
      end

      before do
        school.update_chromebook_information_and_status!(will_need_chromebooks: 'no')
        UpdateSchoolDevicesService.new(school: school,
                                       order_state: :can_order,
                                       laptop_cap: school.allocation(:laptop)).call
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
          expect(school.preorder_status).to eq('rb_can_order')
          expect {
            service.call
          }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_in_virtual_cap).with(params: { user: user, school: school }, args: [])
        end
      end
    end

    context 'when school in virtual college which is ready changes from cannot_order to can_order' do
      let(:responsible_body) { create(:further_education_college, :new_fe_wave) }
      let(:school) do
        create(:fe_school,
               :centrally_managed,
               order_state: order_state,
               responsible_body: responsible_body,
               laptops: [1, 0, 0])
      end

      before do
        school.update_chromebook_information_and_status!(will_need_chromebooks: 'no')
        UpdateSchoolDevicesService.new(school: school,
                                       order_state: :can_order,
                                       laptop_cap: school.allocation(:laptop)).call
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
          expect(school.preorder_status).to eq('rb_can_order')
          expect {
            service.call
          }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_in_fe_college).with(params: { user: user, school: school }, args: [])
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
          }.not_to have_enqueued_mail(CanOrderDevicesMailer)
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
          }.not_to have_enqueued_mail
        end
      end
    end

    context 'when school which is not ready changes from cannot_order to can lockdown order' do
      let(:user) { school.users.first }

      before do
        SchoolSetWhoManagesOrdersService.new(school, :school).call
        school.update_chromebook_information_and_status!(will_need_chromebooks: nil)
      end

      it 'notifies the ordering organisations user' do
        expect(school.preorder_status).to eq('school_contacted')

        expect {
          service.call
        }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_but_action_needed).with(params: { user: user, school: school }, args: [])
      end
    end

    context 'when a school that is not ready changes status from specfic circumstances to lockdown' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order_for_specific_circumstances') }
      let(:user) { create(:school_user, school: school) }

      before do
        school.update!(order_state: 'can_order')
        school.needs_info!
      end

      it 'does not notify the user' do
        expect {
          service.call
        }.not_to have_enqueued_mail(CanOrderDevicesMailer)
      end
    end

    context 'when status change from can_order to cannot_order' do
      let(:school) { create(:school, :with_preorder_information, order_state: 'can_order') }
      let(:user) { create(:school_user, school: school) }

      before do
        school.update!(order_state: 'cannot_order')
        school.needs_info!
      end

      it 'does not notify the user' do
        expect {
          service.call
        }.not_to have_enqueued_mail
      end
    end

    context 'when school preorder needs contact' do
      let(:school) { create_schools_at_status(preorder_status: 'needs_contact') }
      let(:rb) { school.responsible_body }
      let!(:user) { create(:user, responsible_body: rb) }

      before do
        school.update!(raw_laptop_allocation: 10, raw_laptop_cap: 10, raw_laptops_ordered: 0)
        school.can_order!
      end

      it 'nudges RB that school needs a contact' do
        expect {
          service.call
        }.to have_enqueued_mail(CanOrderDevicesMailer, :nudge_rb_to_add_school_contact).with(params: { user: user, school: school }, args: [])
      end
    end

    context 'when the school has no stakeholders' do
      before do
        school.users.destroy_all
      end

      it 'notifies support that school is missing out' do
        expect {
          service.call
        }.to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted).with(params: { school: school }, args: [])
      end
    end

    context 'when a school can order routers' do
      let(:school) do
        create(:school,
               :manages_orders,
               will_need_chromebooks: 'no',
               order_state: :can_order,
               laptops: [1, 0, 0],
               routers: [1, 0, 0])
      end

      let!(:user) do
        create(:school_user,
               school: school,
               techsource_account_confirmed_at: 1.second.ago,
               orders_devices: true)
      end

      before do
        school.increment!(:raw_router_cap)
        school.reload.refresh_preorder_status!
      end

      it 'sends notification they can order routers' do
        expect {
          service.call
        }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_routers).with(params: { school: school, user: user }, args: [])
      end
    end

    context 'when an school in virtual cap can order routers' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
      let(:school) do
        create(:school,
               :centrally_managed,
               order_state: 'can_order',
               responsible_body: responsible_body,
               laptops: [1, 0, 0],
               routers: [1, 0, 0])
      end

      before do
        school.update_chromebook_information_and_status!(will_need_chromebooks: 'no')
        UpdateSchoolDevicesService.new(school: school,
                                       order_state: school.order_state,
                                       router_cap: school.raw_cap(:router) + 1).call
      end

      context 'user has confirmed techsource account' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 responsible_body: responsible_body,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'sends notification they can order routers' do
          expect {
            service.call
          }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_routers_in_virtual_cap).with(params: { user: user, school: school }, args: [])
        end
      end
    end

    context 'when an FESchool can order routers' do
      let(:school) do
        create(:fe_school,
               :manages_orders,
               will_need_chromebooks: 'no',
               order_state: :can_order,
               laptops: [1, 0, 0],
               routers: [1, 0, 0])
      end

      let!(:user) do
        create(:school_user,
               school: school,
               techsource_account_confirmed_at: 1.second.ago,
               orders_devices: true)
      end

      before do
        school.responsible_body.update!(new_fe_wave: true)
        UpdateSchoolDevicesService.new(school: school,
                                       order_state: school.order_state,
                                       router_cap: school.raw_cap(:router) + 1).call
      end

      it 'sends notification they can order routers' do
        expect {
          service.call
        }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order_routers_in_fe_college).with(params: { school: school, user: user }, args: [])
      end
    end

    context 'when school has no devices available (of any type) to order' do
      before do
        school.update!(raw_laptops_ordered: school.cap(:laptop))
        school.update!(raw_routers_ordered: school.cap(:router))
        school.reload
      end

      context 'preconditions' do
        it 'school has no devices available to order (of any type)' do
          expect(school.devices_available_to_order?).to be false
        end
      end

      context 'user has confirmed techsource account' do
        let!(:user) do
          create(:school_user,
                 school: school,
                 techsource_account_confirmed_at: 1.second.ago,
                 orders_devices: true)
        end

        it 'does not notify the user' do
          expect {
            service.call
          }.not_to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order).with(params: { user: user, school: school }, args: [])
        end
      end

      context 'when the school has no stakeholders' do
        before do
          school.users.destroy_all
        end

        it 'does not notify support' do
          expect {
            service.call
          }.not_to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted)
        end
      end

      it 'still notifies Computacenter' do
        expect {
          service.call
        }.to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order).with(params: anything, args: [])
      end
    end

    context 'when school has devices available of one type but not the other' do
      before do
        school.update!(raw_routers_ordered: school.cap(:router))
        school.reload
      end

      context 'preconditions' do
        it 'school has some devices available to order (of any type)' do
          expect(school.devices_available_to_order?).to be true
        end

        it 'one type of allocation is fully ordered but the other is not' do
          expect(school.devices_available_to_order?(:laptop)).to be true
          expect(school.devices_available_to_order?(:router)).to be false
        end
      end

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
          }.to have_enqueued_mail(CanOrderDevicesMailer, :user_can_order).with(params: { user: user, school: school }, args: [])
        end
      end

      context 'when the school has no stakeholders' do
        before do
          school.users.destroy_all
        end

        it 'notifies support that school is missing out' do
          expect {
            service.call
          }.to have_enqueued_mail(CanOrderDevicesMailer, :notify_support_school_can_order_but_no_one_contacted).with(params: { school: school }, args: [])
        end
      end

      it 'still notifies Computacenter' do
        expect {
          service.call
        }.to have_enqueued_mail(ComputacenterMailer, :notify_of_school_can_order).with(params: anything, args: [])
      end
    end
  end
end
