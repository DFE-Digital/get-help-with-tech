require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:sign_in_page) { PageObjects::SignInPage.new }
  let(:responsible_body_home_page) { PageObjects::ResponsibleBody::HomePage.new }

  let(:rb_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let(:responsible_body) { rb_user.responsible_body }

  context 'not signed-in' do
    scenario 'visiting the page redirects to sign-in' do
      visit responsible_body_home_path

      expect(sign_in_page).to be_displayed
    end
  end

  context 'signed in as non-RB user' do
    before do
      sign_in_as mno_user
    end

    scenario 'visiting the page shows a :forbidden error' do
      visit responsible_body_home_path

      expect(page).to have_content("You're not allowed to do that")
      expect(page).to have_http_status(:forbidden)
    end
  end

  context 'signed in as an RB user with the extra_mobile_data_offer FeatureFlag active' do
    before do
      FeatureFlag.activate(:extra_mobile_data_offer)
      sign_in_as rb_user
    end

    scenario 'visiting the page' do
      visit responsible_body_home_path

      expect(responsible_body_home_page).to be_displayed
      expect(page.status_code).to eq 200
      expect(page).to have_text('Request extra data for mobile devices')
    end
  end
end
