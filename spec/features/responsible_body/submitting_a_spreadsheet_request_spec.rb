require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Submitting a bulk ExtraMobileDataRequest request', type: :feature do
  context 'not signed in' do
    it 'does not show the link in the nav' do
      visit '/'
      expect(page).not_to have_text('Tell us who needs more data')
    end

    scenario 'visiting the form directly should redirect to sign_in' do
      visit new_responsible_body_internet_mobile_bulk_request_path
      expect(page).to have_current_path(sign_in_path)
    end
  end

  context 'signed in' do
    let(:user) { create(:local_authority_user) }
    let(:mobile_network) { create(:mobile_network) }

    before do
      mobile_network
      sign_in_as user
      # prevent api call to Notify
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/sms')
        .to_return(status: 201, body: '{}')
    end

    scenario 'Navigating to the form' do
      visit new_responsible_body_internet_mobile_bulk_request_path
      expect(page).to have_text('How would you like to submit information?')
      choose('Using a spreadsheet')
      click_on('Continue')
      expect(page).to have_text('Pick a spreadsheet file')
    end

    scenario 'submitting the form without making a choice shows errors' do
      visit new_responsible_body_internet_mobile_bulk_request_path
      click_on 'Upload requests'
      expect(page.status_code).not_to eq(200)
      expect(page).to have_text('There is a problem')
    end

    scenario 'submitting the form with a valid file shows a summary page' do
      visit new_responsible_body_internet_mobile_bulk_request_path
      attach_file('Pick a spreadsheet file', file_fixture('extra-mobile-data-requests.xlsx'))
      click_on 'Upload requests'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('We’ve processed your spreadsheet')
    end
  end
end
