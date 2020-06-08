require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Session behaviour', type: :feature do
  scenario 'new visitor has sign in link' do
    visit new_application_form_path

    expect(page).to have_text('Sign in')
  end

  context 'with a participating mobile network' do
    before do
      create_participating_mobile_network
    end

    after do
      destroy_participating_mobile_network
    end

    # TODO: need to think about how verification should work
    scenario 'submitting a valid form signs the user in' do
      visit new_application_form_path
      fill_in_valid_application_form
      click_on 'Continue'

      expect(page).to have_text('Sign out')
    end

    scenario 'user session is preserved across requests' do
      visit new_application_form_path
      fill_in_valid_application_form
      click_on 'Continue'
      click_on 'Tell us about another child or young person'
      expect(page).to have_text('Sign out')
    end

    scenario 'clicking "Sign out" signs the user out' do
      visit new_application_form_path
      fill_in_valid_application_form
      click_on 'Continue'

      click_on 'Sign out'
      expect(page).to have_text('Sign in')
    end
  end
end
