require 'rails_helper'
require 'support/sign_in_as'
require 'shared/filling_in_forms'

RSpec.feature 'Submitting an application_form', type: :feature do
  context 'not signed in' do
    it 'does not show the link in the nav' do
      visit '/'
      expect(page).not_to have_text('Tell us how many young people are eligible')
    end

    scenario 'visiting the form directly should redirect to sign_in' do
      visit new_application_form_path
      expect(current_path).to eq(sign_in_path)
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
      visit '/'
      click_on('Tell us who needs more data')
      expect(page).to have_text('Mobile phone number')
    end

    scenario 'submitting the form with invalid params shows errors' do
      visit new_application_form_path
      fill_in 'Mobile phone number', with: '-1'
      click_on 'Continue'
      expect(page.status_code).not_to eq(200)
      expect(page).to have_text('There is a problem')
    end

    scenario 'submitting the form with valid params works' do
      visit new_application_form_path
      fill_in_valid_application_form(mobile_network_name: mobile_network.brand)
      click_on 'Continue'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('Thank you')
      expect(page).to have_text('Sign out')
    end
  end
end
