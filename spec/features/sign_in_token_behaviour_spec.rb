require 'rails_helper'

RSpec.feature 'Sign-in token behaviour', type: :feature do
  let(:user) { create(:local_authority_user, :never_signed_in) }
  let(:ttl) { nil }
  let(:token) { user.generate_token!(ttl: ttl) }
  let(:identifier) { user.sign_in_identifier(token) }

  context 'with a valid sign_in_token link' do
    let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

    context 'that has not expired' do
      let(:ttl) { 3600 }

      scenario 'Visiting a valid sign_in_token link signs the user in' do
        visit validate_token_url
        expect(page).to have_text(user.email_address)
        expect(page).to have_text('Sign out')
      end

      scenario 'Visiting the valid sign_in_token link increments sign-in count and timestamp' do
        timestamp = Date.new(2020, 6, 1)
        Timecop.freeze(timestamp) do
          visit validate_token_url
        end

        expect(user.reload.sign_in_count).to eq(1)
        expect(user.reload.last_signed_in_at).to eq(timestamp)
      end

      scenario 'Visiting a sign_in_token link twice does not work the second time' do
        visit validate_token_url
        click_on 'Sign out'

        visit validate_token_url
        expect(page).to have_http_status(:bad_request)
        expect(page).not_to have_text('Sign out')
      end
    end

    context 'that has expired' do
      let(:ttl) { -1 }

      scenario 'Visiting a valid sign_in_token link after it expires does not sign the user in' do
        visit validate_token_url
        expect(page).to have_http_status(:bad_request)
        expect(page).not_to have_text('Sign out')
      end

      scenario 'Visiting a valid but expired token tells the user it has expired' do
        visit validate_token_url
        expect(page).to have_text('The link you clicked has expired')
        expect(page).to have_link('Request a new sign-in link')
      end
    end
  end

  context 'with an invalid sign_in_token link' do
    let(:broken_token_url) { validate_sign_in_token_url(token: token, identifier: 'abac124') }

    scenario 'Visiting an invalid token link does not sign the user in' do
      visit broken_token_url
      expect(page).not_to have_text('Sign out')
      expect(page).to have_http_status(:bad_request)
      expect(page).to have_text('We didn’t recognise that link')
    end

    scenario 'Visiting an invalid token link allows the user to request a new link' do
      visit broken_token_url
      expect(page).to have_link('Request a new sign-in link', href: sign_in_path)
    end
  end
end
