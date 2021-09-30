require 'rails_helper'

RSpec.feature 'View school details' do
  let(:preorder_information) { create(:preorder_information, :school_will_order, :does_not_need_chromebooks) }
  let(:school) { create(:school, :with_std_device_allocation, preorder_information: preorder_information) }
  let(:user) { create(:school_user, full_name: 'AAA Smith', school: school) }

  describe 'top of the page' do
    let(:school_with_valid_allocation) { create(:school, :with_std_device_allocation, laptops_ordered: 1, preorder_information: preorder_information) }
    let(:user) { create(:school_user, school: school_with_valid_allocation) }

    before { sign_in_as user }

    it 'displays the school name' do
      expect(page).to have_content(school_with_valid_allocation.name)
    end

    it 'displays your account title' do
      expect(page).to have_content('Your account')
    end

    it 'displays the tranche allocation' do
      expect(page).to have_css('#tranche_allocation')
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
      let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

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
    before { sign_in_as user }

    context 'has NOT ordered anything' do
      it 'does not show the order history section' do
        expect(page).not_to have_content('Order history')
      end
    end

    context 'has ordered' do
      let(:school) { create(:school, :with_std_device_allocation_partially_ordered) }

      it 'does NOT show this section' do
        expect(page).not_to have_content('Order history')
      end

      context 'user can order devices' do
        let(:user) { create(:school_user, :orders_devices, full_name: 'AAA Smith', school: school) }

        it 'shows the title' do
          expect(page).to have_content('Order history')
        end

        it 'shows the link to the TechSource order history' do
          expect(page).to have_link('See your order history on TechSource')
        end
      end

      context 'has NOT ordered routers' do
        it 'does NOT show this section' do
          expect(page).not_to have_content('Order history')
        end

        it 'does NOT show the link to the extra mobile data requests page' do
          expect(page).not_to have_link('View your requests for extra mobile data')
        end
      end

      context 'has ordered routers' do
        let(:school) { create(:school, :with_std_device_allocation_partially_ordered, :with_coms_device_allocation_partially_ordered) }

        it 'shows the title' do
          expect(page).to have_content('Order history')
        end

        it 'shows the link to the extra mobile data requests page' do
          expect(page).to have_link('View your requests for extra mobile data')
        end
      end
    end
  end
end
