require 'rails_helper'

RSpec.feature 'Adjusting a schools router allocation' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school, order_state: :cannot_order) }
  let(:school_details_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:enable_orders_confirm_page) { PageObjects::Support::Schools::Devices::EnableOrdersConfirmPage.new }

  before do
    create(:school_device_allocation, :with_coms_allocation, allocation: 50, school: school)
    sign_in_as support_user
  end

  describe 'visiting a school details page' do
    before do
      visit support_school_path(school.urn)
    end

    it 'shows a link to Change whether they can order devices' do
      expect(school_details_page).to have_text 'Router allocation'
      expect(school_details_page).to have_link 'Change router allocation'
    end

    describe 'clicking Change' do
      before do
        click_on 'Change router allocation'
      end

      it 'shows me h1 with Change router allocation' do
        doc = Nokogiri::HTML(page.html)
        expect(doc.css('h1').text).to include('Change router allocation')
      end

      it 'shows me a form to change the allocation' do
        expect(page).to have_field('New allocation')
      end

      context 'filling in an valid value and clicking Save' do
        before do
          fill_in 'New allocation', with: '51'
          click_on 'Save'
        end

        it 'takes me back to the school details page' do
          expect(page).to have_current_path(support_school_path(school.urn))
          expect(page).to have_http_status(:ok)
          expect(page).to have_text('We’ve saved the new allocation')
          expect(school_details_page.school_details_rows[3]).to have_text('51 routers')
        end
      end
    end
  end
end
