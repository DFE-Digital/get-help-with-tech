require 'rails_helper'
require 'shared/filling_in_forms'
require 'support/sidekiq'

RSpec.feature 'Session behaviour', type: :feature do
  scenario 'new visitor has sign in link' do
    visit '/'

    expect(page).to have_text('Sign in')
  end

  context 'when an active session already exists' do
    let(:user) { create(:local_authority_user) }
    let(:validate_token_url) { validate_token_url_for(user) }

    let(:other_user) { create(:mno_user) }
    let(:other_user_magic_link) { validate_token_url_for(other_user) }

    before do
      visit validate_token_url
    end

    scenario 're-using the same magic-link redirects to the home page for user' do
      visit validate_token_url
      click_on 'Continue'
      expect(page).to have_current_path(responsible_body_home_path)
    end

    scenario 'using a new magic link redirects to the home page for user' do
      sign_in_as(user)
      expect(page).to have_current_path(responsible_body_home_path)
    end

    scenario 'using a magic link from a different user signs in as the different user' do
      visit other_user_magic_link
      click_on 'Continue'
      expect(page).to have_content(other_user.email_address)
    end
  end

  context 'with a valid user' do
    let(:valid_user) { create(:local_authority_user) }

    scenario 'Signing in as a recognised user sends a magic link email' do
      visit '/'
      find('.govuk-header__link', text: 'Sign in').click
      expect(page).to have_text('Email address')

      clear_emails
      expect(current_email).to be_nil
      fill_in 'Email address', with: valid_user.email_address
      click_on 'Continue'
      open_email(valid_user.email_address)

      expect(current_email).not_to be_nil
      expect(page).to have_text('Check your email')
    end

    scenario 'Entering an unrecognised email address shows an informative message' do
      visit '/'
      find('.govuk-header__link', text: 'Sign in').click
      expect(page).to have_text('Email address')

      fill_in 'Email address', with: 'unrecognised@example.com'
      click_on 'Continue'

      expect(page).to have_text('We did not recognise that email address')
    end

    scenario 'Entering an invalid email sends the user back to the sign-in page' do
      visit '/'
      find('.govuk-header__link', text: 'Sign in').click
      expect(page).to have_text('Email address')

      clear_emails
      expect(current_email).to be_nil
      fill_in 'Email address', with: 'ab.c'
      click_on 'Continue'

      expect(page).to have_text('Sign in')
      expect(page).to have_text('Enter an email address in the correct format')
    end
  end
end
