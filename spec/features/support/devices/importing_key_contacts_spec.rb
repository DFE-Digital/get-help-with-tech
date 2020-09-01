require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Importing key contacts', type: :feature do
  context 'not signed in' do
    it 'does not show the link in the nav' do
      visit '/'
      expect(page).not_to have_text('Tell us who needs more data')
    end

    scenario 'visiting the form directly should redirect to sign_in' do
      visit new_support_devices_key_contact_path
      expect(page).to have_current_path(sign_in_path)
    end
  end

  context 'signed in but not as support user' do
    let(:user) { create(:trust_user) }

    before do
      sign_in_as user
    end

    scenario 'visiting the form directly should display forbidden error' do
      visit new_support_devices_key_contact_path
      expect(page).to have_selector('h1', text: 'Forbidden')
      expect(page.status_code).to eq(403)
    end
  end

  context 'signed in as support user' do
    let(:user) { create(:dfe_user) }
    let(:responsible_body) { create(:local_authority) }

    before do
      responsible_body
      sign_in_as user
    end

    scenario 'Navigating to the form' do
      visit support_devices_key_contacts_path
      click_on('Import key contacts')
      expect(page).to have_text('Upload a CSV file of key contacts')
    end

    scenario 'submitting the form without making a choice shows errors' do
      visit new_support_devices_key_contact_path
      click_on 'Upload key contacts'
      expect(page.status_code).not_to eq(200)
      expect(page).to have_text('There is a problem')
    end

    scenario 'submitting the form with a valid file shows a summary page' do
      visit new_support_devices_key_contact_path
      attach_file('Pick a CSV file', file_fixture('key_contacts.csv'))
      click_on 'Upload key contacts'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('We’ve processed your file')
    end
  end
end
