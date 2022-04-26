require 'rails_helper'

RSpec.feature 'Managing API tokens', skip: true do
  describe 'signed in as a Computacenter user' do
    let(:user) { create(:computacenter_user) }
    let(:other_user) { create(:computacenter_user) }

    before do
      sign_in_as user
    end

    scenario 'it shows me a form to generate a new token' do
      visit computacenter_api_tokens_path
      expect(page).to have_text 'Generate a new API token'
      expect(page).to have_field 'Name'
    end

    scenario 'clicking Generate without giving a name shows an error' do
      visit computacenter_api_tokens_path
      click_on 'Generate'
      expect(page).to have_text 'There is a problem'
      expect(page).to have_http_status(:unprocessable_entity)
    end

    scenario 'clicking Generate with an invalid name shows an error' do
      visit computacenter_api_tokens_path
      fill_in 'Name', with: 'a'
      click_on 'Generate'
      expect(page).to have_text 'There is a problem'
      expect(page).to have_http_status(:unprocessable_entity)
    end

    scenario 'clicking Generate with a valid name creates the token' do
      visit computacenter_api_tokens_path
      fill_in 'Name', with: 'a new token'
      click_on 'Generate'
      expect(page).to have_text 'a new token'
      expect(page).to have_http_status(:ok)
    end

    context 'when I have existing API tokens' do
      let!(:api_token_1) { create(:api_token, user:, status: 'active') }
      let!(:api_token_2) { create(:api_token, user:) }
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

      scenario 'clicking Revoke revokes the token' do
        click_on 'API tokens'
        within("#api_token-#{api_token_1.id}") do
          click_on 'Revoke'
        end
        within("#api_token-#{api_token_1.id}") do
          expect(page).to have_text 'revoked'
          expect(page).to have_button 'Activate'
        end
      end

      scenario 'clicking Generate with an existing name shows an error' do
        visit computacenter_api_tokens_path
        fill_in 'Name', with: api_token_1.name
        click_on 'Generate'
        expect(page).to have_text 'There is a problem'
        expect(page).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
