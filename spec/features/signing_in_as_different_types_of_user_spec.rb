require 'rails_helper'

RSpec.feature 'Signing-in as different types of user', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:token) { user.generate_token! }
  let(:identifier) { user.sign_in_identifier(token) }
  let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

  scenario 'clicking sign in shows option to sign in' do
    visit sign_in_path
    expect(page).to have_content('Sign in')
  end

  context 'with the public_account_creation FeatureFlag active' do
    before do
      FeatureFlag.activate(:public_account_creation)
    end

    scenario 'supplying a valid email sends a token' do
      visit sign_in_path
      find('#sign-in-token-form-already-have-account-yes-field').choose
      fill_in('Email address', with: user.email_address)
      click_on 'Continue'
      expect(page).to have_content 'Check your email'
    end
  end

  context 'with the public_account_creation FeatureFlag inactive' do
    before do
      FeatureFlag.deactivate(:public_account_creation)
    end

    scenario 'supplying a valid email sends a token' do
      visit sign_in_path
      fill_in('Email address', with: user.email_address)
      click_on 'Continue'
      expect(page).to have_content 'Check your email'
    end
  end

  context 'as a user who belongs_to a responsible_body' do
    let(:user) { create(:local_authority_user) }

    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
    end

    scenario 'it redirects to the responsible_body_home page' do
      sign_in_as user
      expect(page).to have_current_path(responsible_body_home_path)
      expect(page).to have_text 'Increase children’s internet access'
    end
  end

  context 'as a DfE user' do
    let(:user) { create(:dfe_user) }

    scenario 'it redirects to Service performance' do
      sign_in_as user
      expect(page).to have_current_path(support_service_performance_path)
      expect(page).to have_text 'Service performance'
    end
  end

  context 'as a mobile network operator' do
    let(:user) { create(:mno_user) }

    context 'with the extra_mobile_data_offer FeatureFlag active' do
      before do
        FeatureFlag.activate(:extra_mobile_data_offer)
      end

      scenario 'it redirects to Your Requests' do
        sign_in_as user
        expect(page).to have_current_path(mno_extra_mobile_data_requests_path)
        expect(page).to have_text 'Your requests'
      end
    end

    context 'with the extra_mobile_data_offerFeatureFlag inactive' do
      before do
        FeatureFlag.deactivate(:extra_mobile_data_offer)
      end

      it 'redirects to the guidance page' do
        sign_in_as user
        expect(page).to have_current_path(guidance_page_path)
        expect(page).to have_text I18n.t('service_name')
      end
    end
  end
end
