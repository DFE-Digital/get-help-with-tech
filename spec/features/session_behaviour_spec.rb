require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Session behaviour', type: :feature do
  scenario 'new visitor has sign in link' do
    visit new_application_form_path

    expect(page).to have_text('Sign in')
  end

  context 'with a participating mobile network' do
    let(:participating_mobile_network) do
      create(:participating_mobile_network)
    end

    # this seems overly-verbose compared to let!, but this is what rubocop wants
    before do
      participating_mobile_network
    end

    # TODO: need to think about how verification should work
    scenario 'submitting a valid form signs the user in' do
      visit new_application_form_path
      fill_in_valid_application_form(mobile_network_name: participating_mobile_network.brand)
      click_on 'Continue'

      expect(page).to have_text('Sign out')
    end

    scenario 'user session is preserved across requests' do
      visit new_application_form_path
      fill_in_valid_application_form(mobile_network_name: participating_mobile_network.brand)
      click_on 'Continue'
      click_on 'Tell us about another child or young person'
      expect(page).to have_text('Sign out')
    end

    scenario 'clicking "Sign out" signs the user out' do
      visit new_application_form_path
      fill_in_valid_application_form(mobile_network_name: participating_mobile_network.brand)
      click_on 'Continue'

      click_on 'Sign out'
      expect(page).to have_text('Sign in')
    end

    scenario 'submitting a valid form with an existing user email address does not create a duplicate user' do
      user = create(:local_authority_user)
      visit new_application_form_path
      fill_in_valid_application_form(user_email: user.email_address, mobile_network_name: participating_mobile_network.brand)
      expect { click_on 'Continue' }.not_to change(User, :count)
    end
  end

  context 'with a valid user' do
    let(:valid_user) { create(:local_authority_user) }

    scenario 'Signing in as a recognised user sends a magic link email' do
      visit '/'
      click_on 'Sign in'
      expect(page).to have_text('Please enter your email address')

      fill_in 'Please enter your email address', with: valid_user.email_address
      click_on 'Continue'

      expect(page).to have_text('If we’ve recognised the email address you entered, you should receive an email soon containing a link you can click on to sign in.')
    end

    scenario 'Entering an unrecognised email address is silently ignored' do
      visit '/'
      click_on 'Sign in'
      expect(page).to have_text('Please enter your email address')

      fill_in 'Please enter your email address', with: 'unrecognised@example.com'
      click_on 'Continue'

      expect(page).to have_text('If we’ve recognised the email address you entered, you should receive an email soon containing a link you can click on to sign in.')
    end
  end
end
