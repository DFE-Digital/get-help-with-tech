require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:sign_in_page) { PageObjects::SignInPage.new }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }

  let(:responsible_body) { create(:local_authority) }
  let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body) }
  let(:mno_user) { create(:mno_user) }

  context 'not signed-in' do
    scenario 'visiting the page redirects to sign-in' do
      visit responsible_body_home_path

      expect(sign_in_page).to be_displayed
    end
  end

  context 'signed in as non-RB user' do
    before do
      sign_in_as mno_user
    end

    scenario 'visiting the page shows a :forbidden error' do
      visit responsible_body_home_path

      expect(page).to have_content('You’re not allowed to do that')
      expect(page).to have_http_status(:forbidden)
    end
  end

  context 'visiting the RB home page signed in as an RB user' do
    describe 'top of the page' do
      before do
        sign_in_as rb_user
        visit responsible_body_home_path
      end

      it 'displays the school name' do
        expect(page).to have_content(responsible_body.name)
      end

      it 'displays your account title' do
        expect(page).to have_content('Your account')
      end
    end

    context 'RB has virtual cap pool flag' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }

      before do
        stub_request(:post, 'http://computacenter.example.com/')
          .to_return(status: 200, body: '', headers: {})

        schools.each do |s|
          AddSchoolToVirtualCapPoolService.new(s).call
        end
        responsible_body.reload

        sign_in_as rb_user
      end

      context 'has NOT ordered anything' do
        let(:schools) do
          create_list(:school, 4, :centrally_managed, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: responsible_body)
        end

        let(:responsible_body) { create(:local_authority, :manages_centrally, :vcap_feature_flag) }

        it 'ordering closed title' do
          expect(page).to have_content('Ordering is closed for laptops, tablets and extra mobile data')
        end
      end

      context 'has ordered' do
        context 'has ordered laptops and tablets' do
          let(:schools) do
            create_list(:school, 4, :centrally_managed, :with_std_device_allocation_partially_ordered, responsible_body: responsible_body)
          end

          it 'shows the number of laptops and tablets ordered' do
            expect(page).to have_selector('li', text: "#{responsible_body.std_device_pool.devices_ordered} laptops and tablets")
          end
        end

        context 'has ordered routers' do
          let(:schools) do
            create_list(:school, 4, :centrally_managed, :with_coms_device_allocation_partially_ordered, responsible_body: responsible_body)
          end

          it 'shows the number of routers ordered' do
            expect(page).to have_selector('li', text: "#{responsible_body.coms_device_pool.devices_ordered} routers")
          end
        end

        context 'has requested data uplifts' do
          let(:schools) do
            create_list(:school, 4, :centrally_managed, :with_coms_device_allocation, responsible_body: responsible_body)
          end
          let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_extra_mobile_data_requests) }

          it 'shows number of accounts that have received data uplift' do
            expect(page).to have_selector('li', text: 'extra mobile data for 3 accounts')
          end
        end

        context 'multiple assistence' do
          let(:schools) do
            create_list(:school, 4, :centrally_managed, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered, responsible_body: responsible_body)
          end
          let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, :with_extra_mobile_data_requests) }

          it 'show a list of the summaries' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, schools and colleges in your trust received:')
            expect(page).to have_selector('li', text: "#{responsible_body.std_device_pool.devices_ordered} laptops and tablets")
            expect(page).to have_selector('li', text: "#{responsible_body.coms_device_pool.devices_ordered} routers")
            expect(page).to have_selector('li', text: 'extra mobile data for 3 accounts')
          end
        end
      end
    end

    context 'RB has NOT virtual cap pool flag' do
      context 'has NOT ordered anything' do
        before { sign_in_as rb_user }

        it 'ordering closed title' do
          expect(page).to have_content('Ordering is closed for laptops, tablets and extra mobile data')
        end
      end

      context 'has ordered' do
        before do
          school.reload

          sign_in_as rb_user
        end

        context 'has ordered laptops and tablets' do
          let(:school) { create(:school, :with_std_device_allocation_partially_ordered, responsible_body: responsible_body) }

          it 'shows the number of laptops and tablets ordered' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, schools and colleges in your local authority received:')
            expect(page).to have_selector('li', text: "#{school.std_device_allocation.devices_ordered} laptops and tablets")
          end
        end

        context 'has ordered routers' do
          let(:school) { create(:school, :with_coms_device_allocation_partially_ordered, responsible_body: responsible_body) }

          it 'shows the number of routers ordered' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, schools and colleges in your local authority received:')
            expect(page).to have_selector('li', text: "#{school.coms_device_allocation.devices_ordered} routers")
          end
        end

        context 'has requested data uplifts' do
          let(:responsible_body) { create(:local_authority, :with_extra_mobile_data_requests) }
          let(:school) { create(:school, responsible_body: responsible_body) }

          it 'shows number of accounts that have received data uplift' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, schools and colleges in your local authority received:')
            expect(page).to have_selector('li', text: 'extra mobile data for 3 accounts')
          end
        end

        context 'multiple assistence' do
          let(:responsible_body) { create(:local_authority, :with_extra_mobile_data_requests) }
          let(:school) { create(:school, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered, responsible_body: responsible_body) }

          it 'show a list of the summaries' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, schools and colleges in your local authority received:')
            expect(page).to have_selector('li', text: "#{school.std_device_allocation.devices_ordered} laptops and tablets")
            expect(page).to have_selector('li', text: "#{school.coms_device_allocation.devices_ordered} routers")
            expect(page).to have_selector('li', text: 'extra mobile data for 3 accounts')
          end
        end
      end
    end

    describe 'access support portal section' do
      context 'has NOT ordered anything' do
        before { sign_in_as rb_user }

        context 'when a local authority' do
          it 'show a link to manage users' do
            expect(page).to have_link('Manage local authority users')
          end
        end

        context 'when a trust' do
          let(:responsible_body) { create(:trust) }

          it 'show a link to manage trust administrators' do
            expect(page).to have_link('Manage trust administrators')
          end
        end
      end

      context 'has ordered' do
        before do
          create(:school, :with_std_device_allocation_partially_ordered, responsible_body: responsible_body)

          sign_in_as rb_user
        end

        context 'when a local authority' do
          it 'show a link to manage users' do
            expect(page).to have_link('Manage local authority users')
          end
        end

        context 'when a trust' do
          let(:responsible_body) { create(:trust) }

          it 'show a link to manage trust administrators' do
            expect(page).to have_link('Manage trust administrators')
          end
        end
      end
    end

    describe 'reset devices section' do
      context 'has NOT ordered anything' do
        before { sign_in_as rb_user }

        it 'does not show this section' do
          expect(page).not_to have_content('Reset devices')
        end
      end

      context 'has ordered' do
        let(:school) { create(:school, :with_std_device_allocation_partially_ordered, responsible_body: responsible_body) }

        before do
          school.reload

          sign_in_as rb_user
        end

        it 'shows title' do
          expect(page).to have_content('Reset devices')
        end

        it 'shows the link to view device details' do
          expect(page).to have_link('View your device details')
        end

        it 'shows the link to Huawei router password' do
          expect(page).to have_link('See your Huawei router password')
        end
      end
    end

    describe 'order history' do
      context 'has NOT ordered anything' do
        before { sign_in_as rb_user }

        it 'does not show the order history section' do
          expect(page).not_to have_content('Order history')
        end
      end

      context 'has ordered' do
        let(:school) { create(:school, :with_std_device_allocation_partially_ordered, responsible_body: responsible_body) }

        before do
          school.reload

          sign_in_as rb_user
        end

        it 'shows the title' do
          expect(page).to have_content('Order history')
        end

        it 'shows link to view your schools and colleges' do
          expect(page).to have_link('View your schools and colleges')
        end

        context 'user can order devices' do
          let(:rb_user) { create(:local_authority_user, responsible_body: responsible_body, orders_devices: true) }

          it 'shows the link to the TechSource order history' do
            expect(page).to have_link('See your order history on TechSource')
          end
        end

        context 'has NOT ordered routers' do
          it 'does NOT show the link to the extra mobile data requests page' do
            expect(page).not_to have_link('View your requests for extra mobile data')
          end
        end

        context 'has ordered routers' do
          let(:school) { create(:school, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered, responsible_body: responsible_body) }

          it 'shows the link to the extra mobile data requests page' do
            expect(page).to have_link('View your requests for extra mobile data')
          end
        end
      end
    end
  end

  context 'as a first-time RB user' do
    let(:rb_user) { create(:local_authority_user, privacy_notice_seen_at: nil) }

    it 'shows the privacy notice for the first time' do
      sign_in_as rb_user
      expect(page).to have_content('How we look after personal information as part of the Get help with technology programme')

      click_on 'Continue'
      expect(responsible_body_home_page).to be_displayed

      sign_out
      sign_in_as rb_user
      expect(responsible_body_home_page).to be_displayed
    end
  end
end
