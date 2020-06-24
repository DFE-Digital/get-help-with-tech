require 'rails_helper'

RSpec.feature 'Signing-in as different types of user', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:token) { user.generate_token! }
  let(:identifier) { user.sign_in_identifier(token) }
  let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

  scenario 'clicking sign in shows option to sign in' do
    visit sign_in_path
    expect(page).to have_content('Do you already have an account?')
  end

  scenario 'supplying a valid email sends a token' do
    visit sign_in_path
    find('#sign-in-token-form-already-have-account-yes-field').choose
    fill_in('Email address', with: user.email_address)
    click_on 'Continue'
    expect(page).to have_content 'Check your email'
  end

  context 'as a user who is not dfe or mno' do
    let(:user) { create(:local_authority_user) }

    scenario 'it redirects to the guidance page' do
      visit(validate_token_url)
      expect(page).to have_current_path('/about-bt-wifi')
      expect(page).to have_text 'Increasing internet access for vulnerable and disadvantaged children'
    end
  end

  context 'as a dfe user' do
    pending
  end

  context 'as a mobile network operator' do
    let(:user) { create(:mno_user) }

    scenario 'it redirects to Your Requests' do
      visit(validate_token_url)
      expect(page).to have_current_path(mno_recipients_path)
      expect(page).to have_text 'Your requests'
    end
  end
end
