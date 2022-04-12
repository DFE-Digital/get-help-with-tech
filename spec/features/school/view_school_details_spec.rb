require 'rails_helper'

RSpec.feature 'View school details' do
  let(:school) { create(:school, :manages_orders, :does_not_need_chromebooks, laptops: [1, 1, 0]) }
  let(:user) { create(:school_user, full_name: 'AAA Smith', school:) }

  describe 'top of the page' do
    let(:school_with_valid_allocation) do
      create(:school, :manages_orders, :does_not_need_chromebooks, laptops: [1, 1, 0])
    end

    let(:user) { create(:school_user, school: school_with_valid_allocation) }

    before { sign_in_as user }

    it 'displays the school name' do
      expect(page).to have_content(school_with_valid_allocation.name)
    end

    it 'displays your account title' do
      expect(page).to have_content('Your account')
    end

    it 'displays the allocation' do
      expect(page).to have_css('#allocation')
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
      let(:school) { create(:school, laptops: [2, 2, 1]) }

      it 'shows title' do
        expect(page).to have_content('Reset')
      end

      it 'shows the link to view device details' do
        expect(page).to have_link('View your details and BIOS/admin passwords')
      end
    end
  end

  describe 'order history' do
    before { sign_in_as user }

    context 'has NOT ordered anything' do
      it 'does show the order history section' do
        expect(page).to have_content('Order history')
      end
    end

    context 'has ordered' do
      let(:school) { create(:school, :manages_orders, :does_not_need_chromebooks, laptops: [2, 2, 1]) }

      it 'does show this section' do
        expect(page).to have_content('Order history')
      end

      context 'user can order devices' do
        let(:user) { create(:school_user, :orders_devices, full_name: 'AAA Smith', school:) }

        it 'shows the link to the TechSource order history' do
          expect(page).to have_link('Order history')
        end
      end

      context 'has NOT ordered routers' do
        it 'does show this section' do
          expect(page).to have_content('Order history')
        end

        it 'does NOT show the link to the extra mobile data requests page' do
          expect(page).not_to have_link('View your requests for extra mobile data')
        end
      end

      context 'has ordered routers' do
        let(:school) { create(:school, laptops: [2, 2, 1], routers: [2, 2, 1]) }

        it 'shows the title' do
          expect(page).to have_content('Order history')
        end
      end
    end
  end
end
