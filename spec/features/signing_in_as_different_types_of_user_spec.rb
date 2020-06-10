require 'rails_helper'

RSpec.feature 'Sign-in token behaviour', type: :feature do
  let(:token) { user.generate_token! }
  let(:identifier) { user.sign_in_identifier(token) }
  let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

  context 'as a user who is not dfe or mno' do
    let(:user) { create(:local_authority_user) }

    scenario 'it redirects to the guidance page' do
      visit(validate_token_url)
      expect(current_path).to eq('/pages/guidance')
      expect(page).to have_text 'Improving children’s internet access'
    end
  end

  context 'as a dfe user' do
    pending
  end

  context 'as a mobile network operator' do
    let(:user) { create(:mno_user) }

    scenario 'it redirects to Your Requests' do
      visit(validate_token_url)
      expect(response).to redirect_to(mobile_network_recipients_path(user.mobile_network))
      expect(page).to have_text 'Your requests'
    end
  end
end
