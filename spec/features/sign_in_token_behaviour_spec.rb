require 'rails_helper'

RSpec.feature 'Sign-in token behaviour', type: :feature do
  let(:user) { create(:local_authority_user, :never_signed_in) }
  let(:ttl) { nil }
  let(:token) { user.generate_token!(ttl: ttl) }
  let(:identifier) { user.sign_in_identifier(token) }

  context 'with a valid sign_in_token link that has not expired' do
    let(:ttl) { 3600 }
    let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

    describe 'Visiting a valid sign_in_token link' do
      it 'does not sign the user in' do
        visit validate_token_url
        expect(page).not_to have_text(user.email_address)
        expect(page).not_to have_button('Sign out')
        expect(page).to have_text('You’re signed in')
        expect(page).to have_button('Continue')
      end

      it 'does not increment sign-in count' do
        expect { visit validate_token_url }.not_to change(user.reload, :sign_in_count)
      end

      it 'does not change last_signed_in_at' do
        expect { visit validate_token_url }.not_to change(user.reload, :last_signed_in_at)
      end

      it 'works multiple times' do
        3.times do
          visit validate_token_url
          expect(page).to have_http_status(:ok)
          expect(page).to have_text('You’re signed in')
        end
      end
    end

    describe 'clicking the Sign in button' do
      it 'increments sign-in count and last_signed_in_at' do
        timestamp = Time.zone.parse('2020-06-01')
        Timecop.freeze(timestamp) do
          visit validate_token_url
          click_on 'Continue'
        end

        expect(user.reload.sign_in_count).to eq(1)
        expect(user.reload.last_signed_in_at).to eq(timestamp)
      end

      it 'does not work a second time' do
        visit validate_token_url
        click_on 'Continue'
        click_on 'Sign out'

        visit validate_token_url
        expect(page).to have_http_status(:bad_request)
        expect(page).not_to have_text('Sign out')
      end
    end
  end

  context 'with a valid sign_in_token link that has expired' do
    let(:ttl) { -1 }
    let(:validate_token_url) { validate_sign_in_token_url(token: token, identifier: identifier) }

    it 'does not sign the user in' do
      visit validate_token_url
      expect(page).to have_http_status(:bad_request)
      expect(page).not_to have_text('Sign out')
    end

    it 'tells the user it has expired' do
      visit validate_token_url
      expect(page).to have_text('The link you clicked has expired')
      expect(page).to have_link('Request a new sign-in link')
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

  describe 'going directly to the token sent page' do
    context 'with a valid session' do
      let(:user) { create(:school_user) }

      before do
        sign_in_as(user)
      end

      context 'but an invalid token (bug #1798)' do
        it 'does not throw an error' do
          expect { visit sent_token_path(token: 'something_that_does_not_exist') }.not_to raise_error
        end

        it 'renders token_not_recognised with status :bad_request' do
          visit sent_token_path(token: 'something_that_does_not_exist')
          expect(page).to have_content("We didn’t recognise that link")
          expect(page).to have_http_status(:bad_request)
        end
      end
    end
  end
end
