require 'rails_helper'

RSpec.feature 'Public account creation feature flag', type: :feature do
  context 'with the public_account_creation feature flag active' do
    before do
      FeatureFlag.activate(:public_account_creation)
    end

    context 'visiting the sign_in_path' do
      before do
        visit sign_in_path
      end

      it 'shows an option to create an account' do
        expect(page).to have_content 'Create an account'
      end
    end

    context 'visiting the new user page' do
      before do
        visit new_user_path
      end

      it 'allows you to create an account' do
        fill_in 'Your full name', with: 'A Name'
        fill_in 'Email address', with: 'an.address@example.com'
        fill_in 'Organisation you work for', with: 'Some LA'
        click_on 'Create account'
        expect(page).to have_content 'Check your email'
      end
    end
  end

  context 'with the public_account_creation feature flag inactive' do
    before do
      FeatureFlag.deactivate(:public_account_creation)
    end

    context 'visiting the sign_in_path' do
      before do
        visit sign_in_path
      end

      it 'does not show an option to create an account' do
        expect(page).not_to have_content 'Create an account'
      end
    end

    context 'visiting the new user page' do
      before do
        visit new_user_path
      end

      it 'returns a 404' do
        expect(page).to have_http_status :not_found
      end
    end
  end
end
