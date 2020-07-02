require 'rails_helper'
require 'shared/filling_in_forms'

RSpec.feature 'Session behaviour', type: :feature do
  scenario 'new visitor has sign in link' do
    visit new_application_form_path

    expect(page).to have_text('Sign in')
  end

  context 'with a participating mobile network' do
    let(:user) { create(:local_authority_user) }
    let(:participating_mobile_network) do
      create(:mobile_network, participating_in_scheme: true)
    end

    # this seems overly-verbose compared to let!, but this is what rubocop wants
    before do
      participating_mobile_network
    end

    # TODO: need to think about how verification should work
    context 'when signed in' do
      before do
        sign_in_as user
      end

      scenario 'the user can submit a valid form' do
        visit new_application_form_path
        fill_in_valid_application_form(mobile_network_name: participating_mobile_network.brand)
        click_on 'Continue'

        expect(page).to have_text('Thank you')
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
    end

    context 'when the session expires between requests' do
      before do
        sign_in_as user
      end

      scenario 'visiting with a valid but expired session logs the user out' do
        visit new_application_form_path
        fill_in_valid_application_form(mobile_network_name: participating_mobile_network.brand)
        click_on 'Continue'

        sleep(2)
        click_on 'Tell us about another child or young person'
        expect(page).to have_text('Sign in')
      end
    end
  end

  context 'with a valid user' do
    let(:valid_user) { create(:local_authority_user) }

    context 'with the public_account_creation FeatureFlag active' do
      before do
        FeatureFlag.activate(:public_account_creation)
      end

      scenario 'Signing in as a recognised user sends a magic link email' do
        visit '/'
        click_on 'Sign in'
        find('#sign-in-token-form-already-have-account-yes-field').choose if FeatureFlag.active?(:public_account_creation)
        expect(page).to have_text('Email address')

        clear_emails
        expect(current_email).to be_nil
        fill_in 'Email address', with: valid_user.email_address
        click_on 'Continue'
        open_email(valid_user.email_address)

        expect(current_email).not_to be_nil
        expect(page).to have_text('Check your email')
      end

      scenario 'Entering an unrecognised email address is silently ignored' do
        visit '/'
        click_on 'Sign in'
        find('#sign-in-token-form-already-have-account-yes-field').choose if FeatureFlag.active?(:public_account_creation)
        expect(page).to have_text('Email address')

        fill_in 'Email address', with: 'unrecognised@example.com'
        click_on 'Continue'

        expect(page).to have_text('Check your email')
      end
    end

    context 'with the public_account_creation FeatureFlag inactive' do
      before do
        FeatureFlag.deactivate(:public_account_creation)
      end

      scenario 'Signing in as a recognised user sends a magic link email' do
        visit '/'
        click_on 'Sign in'
        expect(page).to have_text('Email address')

        clear_emails
        expect(current_email).to be_nil
        fill_in 'Email address', with: valid_user.email_address
        click_on 'Continue'
        open_email(valid_user.email_address)

        expect(current_email).not_to be_nil
        expect(page).to have_text('Check your email')
      end

      scenario 'Entering an unrecognised email address is silently ignored' do
        visit '/'
        click_on 'Sign in'
        expect(page).to have_text('Email address')

        fill_in 'Email address', with: 'unrecognised@example.com'
        click_on 'Continue'

        expect(page).to have_text('Check your email')
      end
    end
  end
end
