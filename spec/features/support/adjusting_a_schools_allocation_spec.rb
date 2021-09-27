require 'rails_helper'

RSpec.feature 'Adjusting a schools allocation' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school, order_state: :cannot_order) }
  let(:school_details_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:enable_orders_confirm_page) { PageObjects::Support::Schools::Devices::EnableOrdersConfirmPage.new }

  before do
    create(:school_device_allocation, :with_std_allocation, allocation: 50, devices_ordered: 10, school: school)
    stub_computacenter_outgoing_api_calls

    sign_in_as support_user
  end

  describe 'visiting a school details page' do
    before do
      visit support_school_path(school.urn)
    end

    it 'shows a link to Change whether they can order devices' do
      expect(school_details_page).to have_text 'Device allocation'
      expect(school_details_page).to have_link 'Change allocation'
    end

    describe 'clicking Change' do
      before do
        click_on 'Change allocation'
      end

      it 'shows me a form to change the allocation' do
        expect(page).to have_field('New allocation', with: school.std_device_allocation.raw_allocation)
      end

      context 'filling in an invalid value and clicking Save' do
        before do
          fill_in 'New allocation', with: '9'
          click_on 'Save'
        end

        it 'shows me an error' do
          expect(page).to have_http_status(:unprocessable_entity)
          expect(page).to have_text('Allocation cannot be less than the number they have already ordered')
        end
      end

      context 'filling in a valid increased value and clicking Save' do
        before do
          fill_in 'New allocation', with: '51'
          click_on 'Save'
        end

        it 'takes me back to the school details page' do
          expect(page).to have_current_path(support_school_path(school.urn))
          expect(page).to have_http_status(:ok)
          expect(page).to have_text('We’ve saved the new allocation')
          expect(school_details_page.school_details_rows[2]).to have_text(51)
        end
      end

      context 'filling in a valid decreased value and clicking Save' do
        before do
          fill_in 'New allocation', with: '40'
          click_on 'Save'
        end

        it 'takes me back to the school details page' do
          expect(page).to have_current_path(support_school_path(school.urn))
          expect(page).to have_http_status(:ok)
          expect(page).to have_text('We’ve saved the new allocation')
          expect(school_details_page.school_details_rows[2]).to have_text(40)
        end
      end
    end
  end
end
