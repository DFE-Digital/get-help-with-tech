require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Submitting an ExtraMobileDataRequest', type: :feature do
  context 'not signed in' do
    it 'does not show the link in the nav' do
      visit '/'
      expect(page).not_to have_text('Tell us who needs more data')
    end

    scenario 'visiting the form directly should redirect to sign_in' do
      visit new_responsible_body_extra_mobile_data_request_path
      expect(page).to have_current_path(sign_in_path)
    end
  end

  context 'signed in' do
    let(:user) { create(:local_authority_user) }
    let(:mobile_network) { create(:mobile_network) }

    before do
      mobile_network
      sign_in_as user
    end

    scenario 'Navigating to the form' do
      visit responsible_body_extra_mobile_data_requests_path
      click_on('Request data for someone')
      expect(page).to have_text('Mobile phone number')
    end

    scenario 'submitting the form with invalid params shows errors' do
      visit new_responsible_body_extra_mobile_data_request_path
      fill_in 'Mobile phone number', with: '-1'
      click_on 'Continue'
      expect(page.status_code).not_to eq(200)
      expect(page).to have_text('There is a problem')
    end

    scenario 'submitting the form with valid params goes to confirmation page' do
      visit new_responsible_body_extra_mobile_data_request_path
      fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
      click_on 'Continue'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('Check your answers')
      expect(page).to have_text('Sign out')
    end

    scenario 'submitting multiple forms in the same sesssion works' do
      visit new_responsible_body_extra_mobile_data_request_path
      fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
      click_on 'Continue'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('Check your answers')

      click_on 'Confirm request'

      click_on 'Request data for someone'
      fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
      click_on 'Continue'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('Check your answers')
    end
  end
end
