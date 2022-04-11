require 'rails_helper'

RSpec.describe SignInTokensController, type: :controller do
  let(:user) { create(:local_authority_user, :who_has_requested_a_magic_link) }
  let(:valid_token_params) { { token: user.sign_in_token, identifier: user.sign_in_identifier(user.sign_in_token) } }

  before do
    allow(controller).to receive(:save_user_to_session!)
  end

  describe 'destroy' do
    before do
      # Test-only hack - TestSession doesn't auto-create session IDs in
      # controller specs like a Rack Session does.
      create_session_id!
    end

    it 'clears the token when the user provides recognised token & identifier' do
      delete :destroy, params: valid_token_params

      expect(user.reload.sign_in_token).to be_nil
    end

    it 'responds with bad request when the user provides a recognised but expired token & identifier' do
      user.update!(sign_in_token_expires_at: Time.zone.now.utc - 1.hour)
      delete :destroy, params: valid_token_params

      expect(user.reload.sign_in_token).not_to be_nil
      expect(response).to have_http_status(:bad_request)
    end

    it 'saves the user to session' do
      allow(controller).to receive(:save_user_to_session!)
      delete :destroy, params: valid_token_params
      expect(controller).to have_received(:save_user_to_session!)
    end

    context "session['return_url'] is set" do
      it 'redirects to return_url' do
        session['return_url'] = 'https://example.com'

        delete :destroy, params: valid_token_params

        expect(response).to redirect_to('https://example.com')
      end

      it 'deletes it from the session' do
        session['return_url'] = 'https://example.com'

        delete :destroy, params: valid_token_params

        expect(session.key?('return_url')).to be_falsey
      end
    end

    context 'when single_academy_trust user is associated with RB and school' do
      let(:trust) { create(:trust, :single_academy_trust) }
      let(:school) { create(:school, :academy, responsible_body: trust) }
      let(:user) do
        create(:single_academy_trust_user,
               :who_has_requested_a_magic_link,
               orders_devices: true,
               responsible_body: trust,
               school:)
      end

      it 'redirects them to the school journey' do
        delete :destroy, params: valid_token_params
        expect(response).to redirect_to(home_school_path(school))
      end

      context 'when they have not accepted privacy policies' do
        let(:user) do
          create(:local_authority_user,
                 :who_has_requested_a_magic_link,
                 orders_devices: true,
                 privacy_notice_seen_at: nil,
                 school:)
        end

        it 'redirects them to the privacy policy' do
          delete :destroy, params: valid_token_params
          expect(response).to redirect_to(privacy_notice_path)
        end
      end
    end

    context 'when FE college user is associated with RB and school' do
      let(:trust) { create(:further_education_college) }
      let(:school) { create(:fe_school, responsible_body: trust) }
      let(:user) do
        create(:fe_college_user,
               :who_has_requested_a_magic_link,
               orders_devices: true,
               responsible_body: trust,
               school:)
      end

      it 'redirects them to the school journey' do
        delete :destroy, params: valid_token_params
        expect(response).to redirect_to(home_school_path(school))
      end

      context 'when they have not accepted privacy policies' do
        let(:user) do
          create(:fe_college_user,
                 :who_has_requested_a_magic_link,
                 orders_devices: true,
                 privacy_notice_seen_at: nil,
                 school:)
        end

        it 'redirects them to the privacy policy' do
          delete :destroy, params: valid_token_params
          expect(response).to redirect_to(privacy_notice_path)
        end
      end
    end
  end

  describe 'GET #validate' do
    context 'with a valid token' do
      let(:params) { { token: user.sign_in_token, identifier: user.sign_in_identifier(user.sign_in_token) } }

      it 'does not save the user to session' do
        get(:validate, params:)
        expect(controller).not_to have_received(:save_user_to_session!)
      end
    end
  end

  describe '#create' do
    let(:user) { create(:local_authority_user, :who_has_requested_a_magic_link, deleted_at: 1.second.ago) }

    context 'when user has been marked as deleted' do
      it 'does not recognise the email' do
        post :create, params: { sign_in_token_form: { email_address: user.email_address } }
        expect(response).to redirect_to email_not_recognised_path
      end
    end
  end
end
