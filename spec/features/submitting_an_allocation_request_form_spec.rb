require 'rails_helper'

RSpec.feature 'Submitting an allocation_request_form', type: :feature do
  context 'not signed in' do
    it 'does not show the link in the nav' do
      visit '/'
      expect(page).not_to have_text('Tell us how many young people are eligible')
    end

    scenario 'visiting the form directly should redirect to sign_in' do
      visit new_allocation_request_form_path
      expect(page).to have_current_path(sign_in_path)
    end
  end

  context 'signed in' do
    let(:user) { create(:local_authority_user) }

    before do
      sign_in_as user
    end

    scenario 'Navigating to the form' do
      visit '/'
      click_on('Tell us how many young people are eligible')
      expect(page).to have_text('Total number of children and young people eligible for increased internet access')
    end

    scenario 'submitting the form with invalid params shows errors' do
      visit new_allocation_request_form_path
      fill_in 'Total number of children and young people eligible for increased internet access', with: '-1'
      click_on 'Continue'
      expect(page.status_code).not_to eq(200)
      expect(page).to have_text('There is a problem')
    end

    scenario 'submitting the form with valid params works' do
      visit new_allocation_request_form_path
      fill_in 'Total number of children and young people eligible for increased internet access', with: 2
      fill_in 'Total number of eligible children and young people who can access a BT hotspot', with: 1
      click_on 'Continue'

      expect(page.status_code).to eq(200)
      expect(page).to have_text('Thank you')
      expect(page).to have_text('Sign out')
    end
  end
end
