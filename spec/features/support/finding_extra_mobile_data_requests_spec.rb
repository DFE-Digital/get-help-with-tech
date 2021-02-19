require 'rails_helper'

RSpec.describe 'Finding ExtraMobileDataRequests in support' do
  let(:support_user) { create(:support_user) }
  let(:computacenter_user) { create(:computacenter_user) }
  let(:index_page) { PageObjects::Support::ExtraMobileDataRequests::IndexPage.new }
  let!(:requests) { create_list(:extra_mobile_data_request, 10) }

  context 'as a support_user' do
    before do
      sign_in_as support_user
    end

    context 'when I visit support home' do
      before do
        visit support_home_path
      end

      it 'shows me a link for Extra mobile data requests' do
        expect(page).to have_link 'Find requests for extra mobile data'
      end

      context 'clicking on the link' do
        before do
          click_on 'Find requests for extra mobile data'
        end

        it 'shows me the requests list' do
          expect(index_page).to be_displayed
        end

        it 'only shows the first and last characters of account holder names' do
          requests.each do |r|
            expect(index_page).not_to have_content(r.account_holder_name)
            expect(index_page).to have_content([r.account_holder_name.first, r.account_holder_name.last].join('…'))
          end
        end

        it 'only shows the first 2 and last 4 characters of the mobile numbers' do
          requests.each do |r|
            expect(index_page).not_to have_content(r.device_phone_number)
            expect(index_page).to have_content([r.device_phone_number.first(2), r.device_phone_number.last(4)].join('…'))
          end
        end

        it 'shows me the search form' do
          expect(index_page).to have_content 'Search for requests'
        end
      end
    end

    context 'when I click to Search for requests' do
      before do
        visit support_extra_mobile_data_requests_path
        index_page.search_for_requests.click
      end

      context 'and I search by request ID' do
        let(:request) { requests.last }

        before do
          fill_in 'Request ID', with: request.id
          click_on 'Search'
        end

        it 'shows me only that request' do
          expect(index_page.request_rows.size).to eq(1)
          expect(index_page.row_for(request)).to have_content(request.id)
        end
      end

      context 'when I search by mobile network' do
        let(:request) { requests.sample }

        before do
          select(request.mobile_network.brand, from: 'Mobile network')
          click_on 'Search'
        end

        it 'shows me only requests with that brand' do
          expect(index_page.request_brands.map(&:text).uniq).to eql(Array(request.mobile_network.brand))
        end
      end
    end
  end
end
