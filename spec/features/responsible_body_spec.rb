require 'rails_helper'

RSpec.feature ResponsibleBody do
  let(:sign_in_page) { PageObjects::SignInPage.new }
  let(:responsible_body_page) { PageObjects::ResponsibleBodyPage.new }
  let(:user) { create :local_authority_user }

  context "user that isn't signed in" do
    scenario 'visiting the page' do
      visit responsible_body_path

      expect(sign_in_page).to be_displayed
    end
  end

  context 'signed-in user' do
    before do
      sign_in_as user
    end

    scenario 'visiting the page' do
      visit responsible_body_path

      expect(responsible_body_page).to be_displayed
      expect(page.status_code).to eq 200
    end
  end
end
