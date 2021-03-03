require 'rails_helper'

RSpec.feature 'Signing-in as different types of user', type: :feature do
  let(:user) { create(:local_authority_user) }
  let(:local_authority_school) { create(:school, :la_maintained, responsible_body: user.responsible_body) }
  let(:single_academy_trust) { create(:school, :single_academy_trust) }
  let(:single_academy_trust_user) { create(:user, :single_academy_trust_user) }
  let(:fe_college_user) { create(:user, :fe_college_user) }

  let(:token) { user.generate_token! }
  let(:identifier) { user.sign_in_identifier(token) }
  let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

  before do
    # disable computacenter user import API calls
    allow(Settings.computacenter.service_now_user_import_api).to receive(:endpoint).and_return(nil)
  end

  scenario 'clicking sign in shows option to sign in' do
    visit sign_in_path
    expect(page).to have_content('Sign in')
  end

  context 'user has already signed in' do
    let(:user) { create(:local_authority_user, :has_seen_privacy_notice) }

    scenario 'visiting sign in when already signed in redirects user to home page' do
      sign_in_as user
      visit sign_in_path
      expect(page).to have_current_path(responsible_body_home_path)
      expect(page).to have_text 'Get help with technology'
    end

    scenario 'visiting start page when already signed in redirects user to home page' do
      sign_in_as user
      visit start_path
      expect(page).to have_current_path(responsible_body_home_path)
      expect(page).to have_text 'Get help with technology'
    end
  end

  scenario 'supplying a valid email sends a token' do
    visit sign_in_path
    fill_in('Email address', with: user.email_address)
    click_on 'Continue'
    expect(page).to have_content 'Check your email'
    expect(page).not_to have_content('Sign out')
    expect(page).not_to have_content('/token/validate?identifier=')
  end

  scenario 'when feature display_sign_in_token_links is active', with_feature_flags: { display_sign_in_token_links: 'active' } do
    visit sign_in_path
    fill_in('Email address', with: user.email_address)
    click_on 'Continue'
    expect(page).to have_content('/token/validate?identifier=')
  end

  context 'as a user who belongs to a responsible body' do
    context 'who has already seen the privacy notice' do
      let(:user) { create(:local_authority_user, :has_seen_privacy_notice, orders_devices: true) }

      scenario 'it redirects to the responsible body homepage' do
        sign_in_as user
        expect(page).to have_current_path(responsible_body_home_path)
        expect(page).to have_text 'Get help with technology'
      end

      context 'and who also belongs to a school' do
        before do
          user.schools << local_authority_school
        end

        scenario 'it redirects to Your organisations' do
          sign_in_as user
          expect(page).to have_text 'Your organisations'
          expect(page).to have_link user.schools[0].name
          expect(page).to have_link user.responsible_body.name
        end
      end
    end

    context 'who has not seen the privacy notice' do
      let(:user) { create(:local_authority_user, :has_not_seen_privacy_notice) }

      scenario 'it redirects to the privacy notice page' do
        sign_in_as user
        expect(page).to have_current_path(privacy_notice_path)
        expect(page).to have_text 'Privacy notice'
      end
    end
  end

  context 'as a school user who has completed the welcome wizard' do
    let(:user) { create(:school_user) }

    context 'who has not seen the privacy notice' do
      let(:user) { create(:school_user, :has_not_seen_privacy_notice) }

      scenario 'it redirects to the privacy notice page' do
        sign_in_as user
        expect(page).to have_current_path(privacy_notice_path)
        expect(page).to have_text 'Privacy notice'
      end
    end

    context 'when the user has only one school' do
      scenario 'it redirects to the school homepage' do
        sign_in_as user
        expect(page).to have_current_path(home_school_path(user.school))
        expect(page).to have_text user.school.name
      end
    end

    context 'if the user has multiple schools' do
      let(:other_school) { create(:school) }

      before do
        user.schools << other_school
      end

      scenario 'it takes them to Your schools' do
        visit validate_token_url_for(user)
        click_on 'Continue'
        expect(page).to have_text 'Your schools'
        expect(page).to have_text user.schools[0].name
        expect(page).to have_text user.schools[1].name
      end
    end
  end

  context 'as a school user who has completed the welcome wizard but not decided on chromebooks' do
    let(:preorder) { create(:preorder_information, :school_will_order) }
    let(:school) { create(:school, preorder_information: preorder) }
    let(:user) { create(:school_user, school: school) }

    scenario 'it redirects to the before you can order page' do
      sign_in_as user
      expect(page).to have_current_path(before_you_can_order_school_path(school))
      expect(page).to have_text 'Before you can order'
      choose 'I don’t know'
      click_on 'Save'
      expect(page).to have_text user.school.name
    end
  end

  context 'as a school user who has not done any of the welcome wizard' do
    let(:user) { create(:school_user, :new_visitor, :has_not_seen_privacy_notice) }

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

    context 'when the user orders_devices' do
      let(:user) { create(:school_user, :new_visitor, :has_not_seen_privacy_notice, orders_devices: true) }

      describe 'continuing after the privacy notice' do
        before do
          visit validate_token_url_for(user)
          click_on 'Continue'
        end

        it 'adds a Computacenter::UserChange record for the user' do
          expect { click_on 'Continue' }.to change(Computacenter::UserChange, :count).by(1)
          expect(Computacenter::UserChange.last).to have_attributes(user_id: user.id, type_of_update: 'New')
        end
      end
    end

    context 'when the user does not order devices' do
      let(:user) { create(:school_user, :new_visitor, :has_not_seen_privacy_notice, orders_devices: false) }

      describe 'continuing after the privacy notice' do
        before do
          visit validate_token_url_for(user)
          click_on 'Continue'
        end

        it 'does not add a Computacenter::UserChange record for the user' do
          expect { click_on 'Continue' }.not_to change(Computacenter::UserChange, :count)
        end
      end
    end
  end

  context 'as a school user who has only done part of the welcome wizard' do
    let(:user) { create(:school_user, :has_partially_completed_wizard) }

    scenario 'clicking on Sign in takes them to their next step' do
      visit validate_token_url_for(user)
      click_on 'Continue'
      expect(page).to have_text 'You will need to place orders on a website called TechSource'
    end
  end

  context 'as a single_academy_trust user' do
    let(:user) { create(:single_academy_trust_user, :has_not_seen_privacy_notice) }

    scenario 'logging in for the first time' do
      visit validate_token_url_for(user)
      expect(page).to have_text("You’re signed in as #{user.school.name}")
      click_on 'Continue'
      expect(page).to have_text('Before you continue, please read the privacy notice.')
      click_on 'Continue'
      expect(page).to have_text('You’ve been allocated 0 laptops')
    end
  end

  context 'as a fe college user' do
    let(:user) { create(:fe_college_user, :has_not_seen_privacy_notice) }

    scenario 'logging in for the first time' do
      visit validate_token_url_for(user)
      expect(page).to have_text("You’re signed in as #{user.school.name}")
      click_on 'Continue'
      expect(page).to have_text('Before you continue, please read the privacy notice.')
      click_on 'Continue'
      expect(page).to have_text('You’ve been allocated 0 laptops')
    end
  end

  context 'as a support user' do
    let(:user) { create(:dfe_user) }

    scenario 'it redirects to internet service performance' do
      sign_in_as user
      expect(page).to have_current_path(support_home_path)
      expect(page).to have_text 'Support'
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
