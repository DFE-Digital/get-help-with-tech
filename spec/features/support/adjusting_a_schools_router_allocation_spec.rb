require 'rails_helper'

RSpec.feature 'Adjusting a schools router allocation' do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school, order_state: :cannot_order, routers: [50, 1, 0]) }
  let(:school_details_page) { PageObjects::Support::SchoolDetailsPage.new }
  let(:enable_orders_confirm_page) { PageObjects::Support::Schools::Devices::EnableOrdersConfirmPage.new }

  before do
    sign_in_as support_user
    stub_computacenter_outgoing_api_calls
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
          expect(school_details_page.school_details_rows[3]).to have_text('routers are not available')
        end
      end
    end
  end
end
