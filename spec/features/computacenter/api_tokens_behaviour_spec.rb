require 'rails_helper'

RSpec.feature 'Managing API tokens' do
  describe 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let(:other_user) { create(:computacenter_user) }

    before do
      sign_in_as user
    end

    context 'when I have existing API tokens' do
      let!(:api_token_1) { create(:api_token, user: user) }
      let!(:api_token_2) { create(:api_token, user: user) }
      let!(:other_user_api_token) { create(:api_token, user: other_user) }

      scenario 'clicking on the API tokens nav link shows me a list of my API tokens' do
        click_on 'API tokens'
        expect(page).to have_text 'Your API tokens'
        expect(page).to have_text api_token_1.name
        expect(page).to have_text api_token_2.name
      end

      scenario 'clicking on the API tokens nav link does not show me any other users API tokens' do
        click_on 'API tokens'
        expect(page).to have_text 'Your API tokens'
        expect(page).not_to have_text other_user_api_token.name
      end
    end
  end
end
