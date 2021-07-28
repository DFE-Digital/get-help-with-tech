require 'rails_helper'

RSpec.feature 'View school details' do
  let(:preorder_information) { create(:preorder_information, :school_will_order, :does_not_need_chromebooks) }
  let(:school) { create(:school, :with_std_device_allocation, preorder_information: preorder_information) }
  let(:user) { create(:school_user, full_name: 'AAA Smith', school: school) }

  describe 'top of the page' do
    before { sign_in_as user }

    it 'displays the school name' do
      expect(page).to have_content(school.name)
    end

    it 'displays your account title' do
      expect(page).to have_content('Your account')
    end
  end

  describe 'banner' do
    describe 'title' do
      before { sign_in_as user }

      it 'shows banner title for ordering is closed' do
        expect(page).to have_content('Ordering is closed for laptops')
      end
    end

    context 'school in virtual cap pool' do
      let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }
      let(:school) { schools.first }

      before do
        stub_request(:post, 'http://computacenter.example.com/')
          .to_return(status: 200, body: '', headers: {})

        schools.each do |s|
          responsible_body.add_school_to_virtual_cap_pools!(s)
          responsible_body.calculate_virtual_caps!
        end

        sign_in_as user
      end

      context 'has NOT ordered anything' do
        let(:schools) do
          create_list(:school, 4, :centrally_managed, :with_std_device_allocation, :with_coms_device_allocation, responsible_body: responsible_body)
        end

        let(:responsible_body) { create(:local_authority, :manages_centrally, :vcap_feature_flag) }

        it 'says 4G routers are available to order till 31 July' do
          expect(page).to have_content('4G wireless routers are available to order until 31 July.')
        end
      end

      context 'has ordered' do
        context 'has ordered laptops and tablets' do
          let(:schools) do
            create_list(:school, 4, :centrally_managed, :with_std_device_allocation_partially_ordered, responsible_body: responsible_body)
          end

          it 'shows the number of laptops and tablets ordered' do
            expect(page).to have_selector('li', text: "#{school.std_device_allocation.devices_ordered} laptops and tablets")
          end
        end

        context 'has ordered routers' do
          let(:schools) do
            create_list(:school, 4, :centrally_managed, :with_coms_device_allocation_partially_ordered, responsible_body: responsible_body)
          end

          it 'shows the number of routers ordered' do
            expect(page).to have_selector('li', text: "#{school.coms_device_allocation.devices_ordered} routers")
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
            expect(page).to have_selector('li', text: "#{school.std_device_allocation.devices_ordered} laptops and tablets")
            expect(page).to have_selector('li', text: "#{school.coms_device_allocation.devices_ordered} routers")
            expect(page).to have_selector('li', text: 'extra mobile data for 3 accounts')
          end
        end
      end
    end

    context 'school NOT in virtual cap pool' do
      before { sign_in_as user }

      context 'has NOT ordered anything' do
        it 'says 4G routers are available to order till 31 July' do
          expect(page).to have_content('4G wireless routers are available to order until 31 July.')
        end
      end

      context 'has ordered' do
        context 'has ordered laptops and tablets' do
          let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

          it 'shows the number of laptops and tablets ordered' do
            expect(page).to have_selector('p', text: "From September 2020 to July 2021, your school received #{school.std_device_allocation.devices_ordered} laptops and tablets.")
          end
        end

        context 'has ordered routers' do
          let(:school) { create(:school, :with_coms_device_allocation_partially_ordered) }

          it 'shows the number of routers ordered' do
            expect(page).to have_selector('p', text: "From September 2020 to July 2021, your school received #{school.coms_device_allocation.devices_ordered} routers.")
          end
        end

        context 'has requested data uplifts' do
          let(:school) { create(:school, :with_extra_mobile_data_requests) }

          it 'shows number of accounts that have received data uplift' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, your school received extra mobile data for 2 accounts')
          end
        end

        context 'multiple assistence' do
          let(:school) { create(:school, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered, :with_extra_mobile_data_requests) }

          it 'show a list of the summaries' do
            expect(page).to have_selector('p', text: 'From September 2020 to July 2021, your school received:')
            expect(page).to have_selector('li', text: "#{school.std_device_allocation.devices_ordered} laptops and tablets")
            expect(page).to have_selector('li', text: "#{school.coms_device_allocation.devices_ordered} routers")
            expect(page).to have_selector('li', text: 'extra mobile data for 2 accounts')
          end
        end
      end
    end
  end

  describe 'access support portal section' do
    before { sign_in_as user }

    context 'has NOT ordered anything' do
      it 'shows the title' do
        expect(page).to have_content('Access the Support Portal')
      end

      it 'show a link to manage users' do
        expect(page).to have_link('Manage who can access the Support Portal')
      end
    end

    context 'has ordered' do
      let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

      describe 'common content' do
        it 'shows the title' do
          expect(page).to have_content('Access the Support Portal')
        end

        it 'shows use support title blurb' do
          expect(page).to have_content('Use the Support Portal to get local admin and BIOS passwords.')
        end

        it 'show a link to manage users' do
          expect(page).to have_link('Manage who can access the Support Portal')
        end
      end

      context 'user can order devices' do
        let(:user) { create(:school_user, :orders_devices, full_name: 'AAA Smith', school: school) }

        it 'shows a link to the CC support portal' do
          expect(page).to have_link('Visit the Support Portal')
        end
      end

      context 'user cannot order devices' do
        it 'does NOT show a link to the CC support portal' do
          expect(page).not_to have_link('Visit the Support Portal')
        end

        it 'shows you do not have access' do
          expect(page).to have_content('Up to 3 people from your school can access the Support Portal. You do not have access to the Support Portal.')
        end
      end
    end
  end

  describe 'reset devices section' do
    before { sign_in_as user }

    context 'has NOT ordered anything' do
      it 'does not show this section' do
        expect(page).not_to have_content('Reset devices')
      end
    end

    context 'has ordered' do
      context 'has ordered laptops and tablets only' do
        let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

        it 'shows title' do
          expect(page).to have_content('Reset devices')
        end

        it 'shows deadline' do
          expect(page).to have_content('Windows laptops and tablets need to be reset before 30 September 2021')
        end

        it 'shows link to reset devices' do
          expect(page).to have_link('How to reset Windows laptops and tablets')
        end
      end

      context 'has ordered routers only' do
        let(:school) { create(:school, :with_coms_device_allocation_partially_ordered) }

        it 'shows title' do
          expect(page).to have_content('Reset devices')
        end

        it 'shows deadline' do
          expect(page).to have_content('Huawei routers need to be reset before 16 July 2021.')
        end

        it 'shows link to reset wireless routers' do
          expect(page).to have_link('How to reset wireless routers')
        end

        it 'shows the link to Huawei router password' do
          expect(page).to have_link('See your Huawei router password')
        end
      end

      context 'has ordered both' do
        let(:school) { create(:school, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered) }

        it 'shows title' do
          expect(page).to have_content('Reset devices')
        end

        it 'shows deadlines in list and links after' do
          expect(page).to have_selector('li', text: 'Windows laptops and tablets need to be reset before 30 September 2021')
          expect(page).to have_selector('li', text: 'Huawei routers need to be reset before 16 July 2021')

          expect(page).to have_link('How to reset Windows laptops and tablets')
          expect(page).to have_link('How to reset wireless routers')
          expect(page).to have_link('See your Huawei router password')
        end
      end
    end
  end

  describe 'order history' do
    before { sign_in_as user }

    context 'has NOT ordered anything' do
      it 'does not show the order history section' do
        expect(page).not_to have_content('Order history')
      end
    end

    context 'has ordered' do
      let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

      it 'shows the title' do
        expect(page).to have_content('Order history')
      end

      context 'user can order devices' do
        let(:user) { create(:school_user, :orders_devices, full_name: 'AAA Smith', school: school) }

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
        let(:school) { create(:school, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered) }

        it 'shows the link to the extra mobile data requests page' do
          expect(page).to have_link('View your requests for extra mobile data')
        end
      end
    end
  end
end
