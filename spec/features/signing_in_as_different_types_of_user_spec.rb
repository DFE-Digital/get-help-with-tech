require 'rails_helper'

RSpec.feature 'Signing-in as different types of user', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:token) { user.generate_token! }
  let(:identifier) { user.sign_in_identifier(token) }
  let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

  before do
    # disable computacenter user import API calls
    Settings.computacenter.service_now_user_import_api.endpoint = nil
    stub_request(:post, Settings.slack.event_notifications.webhook_url).to_return(status: 200, body: '')
  end

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
      expect(page).not_to have_content('Sign out')
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
      expect(page).not_to have_content('Sign out')
    end
  end

  context 'as a user who belongs to a responsible body' do
    context 'who has already seen the privacy notice' do
      let(:user) { create(:local_authority_user, :has_seen_privacy_notice) }

      scenario 'it redirects to the responsible body homepage' do
        sign_in_as user
        expect(page).to have_current_path(responsible_body_home_path)
        expect(page).to have_text 'Get help with technology'
      end
    end

    context 'who has not seen the privacy notice' do
      let(:user) { create(:local_authority_user, privacy_notice_seen_at: nil) }

      scenario 'it redirects to the privacy notice page' do
        sign_in_as user
        expect(page).to have_current_path(responsible_body_privacy_notice_path)
        expect(page).to have_text 'Privacy notice'
      end
    end
  end

  context 'as a school user who has completed the welcome wizard' do
    let(:user) { create(:school_user) }

    scenario 'it redirects to the school homepage' do
      sign_in_as user
      expect(page).to have_current_path(school_home_path)
      expect(page).to have_text 'Get devices for your school'
    end
  end

  context 'as a school user who has completed the welcome wizard but not decided on chromebooks' do
    let(:preorder) { create(:preorder_information, :school_will_order) }
    let(:school) { create(:school, preorder_information: preorder) }
    let(:user) { create(:school_user, school: school) }

    scenario 'it redirects to the before you can order page' do
      sign_in_as user
      expect(page).to have_current_path(school_before_you_can_order_path)
      expect(page).to have_text 'Before you can order'
      choose 'I don’t know'
      click_on 'Save'
      expect(page).to have_text 'Get devices for your school'
    end
  end

  context 'as a school user who has not done any of the welcome wizard' do
    let(:user) { create(:school_user, :new_visitor) }

    scenario 'it shows the welcome wizard welcome text on the interstitial page' do
      visit validate_token_url_for(user)
      expect(page).to have_text "You’re signed in as #{user.school.name}"
      expect(page).to have_text 'You can use the ‘Get help with technology’ service to:'
    end

    scenario 'clicking on Sign in shows them the privacy notice' do
      visit validate_token_url_for(user)
      expect(page).to have_text "You’re signed in as #{user.school.name}"
      click_on 'Continue'
      expect(page).to have_text 'Before you continue, please read the privacy notice.'
    end
  end

  context 'as a school user who has not done part of the welcome wizard' do
    let(:user) { create(:school_user, :has_partially_completed_wizard) }

    scenario 'clicking on Sign in takes them to their next step' do
      visit validate_token_url_for(user)
      click_on 'Continue'
      expect(page).to have_text 'You will need to place orders on a website called TechSource'
    end
  end

  context 'as a hybrid user' do
    let(:user) { create(:hybrid_user) }

    scenario 'logging in for the first time' do
      visit validate_token_url_for(user)
      expect(page).to have_text("You’re signed in as #{user.school.name}")
      click_on 'Continue'
      expect(page).to have_text('Before you continue, please read the privacy notice.')
      click_on 'Continue'
      expect(page).to have_text('You’ve been allocated 0 laptops and tablets')
    end
  end

  context 'as a support user' do
    let(:user) { create(:dfe_user) }

    scenario 'it redirects to internet service performance' do
      sign_in_as user
      expect(page).to have_current_path(support_internet_service_performance_path)
      expect(page).to have_text 'Service performance'
    end

    context 'who is also attached to a responsible body (for demo purposes)' do
      let(:user) { create(:local_authority_user, is_support: true) }

      scenario 'it redirects to the responsible body homepage' do
        sign_in_as user
        expect(page).to have_current_path(responsible_body_home_path)
        expect(page).to have_text 'Get help with technology'
      end
    end
  end

  context 'as a mobile network operator' do
    let(:user) { create(:mno_user) }

    scenario 'it redirects to Your Requests' do
      sign_in_as user
      expect(page).to have_current_path(mno_extra_mobile_data_requests_path)
      expect(page).to have_text 'Your requests'
    end
  end

  context 'as a computacenter operator' do
    let(:user) { create(:computacenter_user) }

    scenario 'it redirects to the computacenter home page' do
      sign_in_as user
      expect(page).to have_current_path(computacenter_home_path)
      expect(page).to have_text 'TechSource'
    end
  end
end
