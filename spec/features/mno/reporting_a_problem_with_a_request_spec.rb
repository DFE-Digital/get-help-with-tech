require 'rails_helper'

RSpec.feature 'Reporting a problem with an ExtraMobileDataRequest', type: :feature do
  let(:mno_user) { create(:mno_user) }

  context 'with extra_mobile_data_offer FeatureFlag active, and 2 existing requests' do
    let(:requests) { create_list(:extra_mobile_data_request, 2, mobile_network: mno_user.mobile_network) }

    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
      requests
      sign_in_as mno_user
      visit mno_extra_mobile_data_requests_path
    end

    scenario 'clicking "Report a problem" shows the "Report a problem" form' do
      within("#request-#{requests.first.id}") do
        click_on('Report a problem')
      end

      expect(page).to have_content('Report a problem')
    end

    scenario 'submitting the form without choosing a problem returns an error' do
      within("#request-#{requests.first.id}") do
        click_on('Report a problem')
      end

      click_on 'Report problem'

      expect(page).to have_http_status(:unprocessable_entity)
    end

    scenario 'choosing a problem and submitting the form updates the status of the request' do
      within("#request-#{requests.first.id}") do
        click_on('Report a problem')
      end

      choose 'This account is no longer on our network'
      click_on 'Report problem'

      within("#request-#{requests.first.id}") do
        expect(page).to have_content('Not on network')
        expect(page).to have_link('Change problem')
      end
    end
  end

  context 'with the extra_mobile_data_request FeatureFlag inactive' do
    before do
      FeatureFlag.deactivate(:extra_mobile_data_offer)
      sign_in_as mno_user
      visit mno_extra_mobile_data_requests_path
    end

    it 'returns a 404' do
      visit mno_extra_mobile_data_requests_path
      expect(page).to have_http_status(:not_found)
      expect(page).to have_text('Page not found')
    end
  end
end
