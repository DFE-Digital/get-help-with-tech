require 'rails_helper'

RSpec.describe SignInTokensController, type: :controller do
  let(:user) { create(:local_authority_user, :who_has_requested_a_magic_link) }
  let(:valid_token_params) { { token: user.sign_in_token, identifier: user.sign_in_identifier(user.sign_in_token) } }
  let(:mock_event) { instance_double(SignInEvent, notifiable?: false) }

  before do
    allow(controller).to receive(:save_user_to_session!)
    allow(SignInEvent).to receive(:new).with(user: user).and_return(mock_event)
    allow(EventNotificationsService).to receive(:broadcast)
  end

  describe 'destroy' do
    before do
      # Test-only hack - TestSession doesn't auto-create session IDs in
      # controller specs like a Rack Session does.
      create_session_id!
      allow(EventNotificationsService).to receive(:broadcast)
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

    it 'broadcasts a SignInEvent for the user' do
      delete :destroy, params: valid_token_params
      expect(EventNotificationsService).to have_received(:broadcast).with(mock_event)
    end
  end

  describe 'GET #validate' do
    context 'with a valid token' do
      let(:params) { { token: user.sign_in_token, identifier: user.sign_in_identifier(user.sign_in_token) } }

      it 'does not save the user to session' do
        get :validate, params: params
        expect(controller).not_to have_received(:save_user_to_session!)
      end

      it 'does not broadcast a SignInEvent for the user' do
        get :validate, params: params
        expect(EventNotificationsService).not_to have_received(:broadcast)
      end
    end
  end
end
