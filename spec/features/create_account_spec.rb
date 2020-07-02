require 'rails_helper'

RSpec.feature 'Creating an account', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:new_user) { build(:local_authority_user) }

  context 'with public_account_creation FeatureFlag active' do
    before do
      FeatureFlag.activate(:public_account_creation)
    end

    scenario 'clicking sign in shows option to create an account' do
      visit sign_in_path
      expect(page).to have_content('Do you already have an account?')
      expect(page).to have_content('No, I need to create an account')
    end

    scenario 'supplying valid info sends a token via email' do
      visit sign_in_path
      find('#sign-in-token-form-already-have-account-no-field').choose
      click_on('Continue')

      fill_in('Email address', with: new_user.email_address)
      fill_in('Your full name', with: new_user.full_name)
      fill_in('Organisation you work for', with: new_user.organisation)
      click_on 'Create account'
      expect(page).to have_content 'Check your email'
    end
  end
end
