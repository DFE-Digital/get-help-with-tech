require 'rails_helper'

RSpec.describe SignInTokensController, type: :controller do
  let(:user) { create(:local_authority_user, :who_has_requested_a_magic_link) }

  describe 'destroy' do
    it 'clears the token when the user is signed in' do
      sign_in_as user

      delete :destroy

      expect(user.reload.sign_in_token).to be_nil
    end

    it 'redirects to the sign-in path if the user is not signed in' do
      delete :destroy

      expect(user.reload.sign_in_token).not_to be_nil
      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe 'GET #validate' do
    context 'with a valid token' do
      let(:params) { { token: user.sign_in_token, identifier: user.sign_in_identifier(user.sign_in_token) } }
      let(:mock_event) { instance_double(SignInEvent, notifiable?: false) }

      before do
        allow(controller).to receive(:save_user_to_session!)
        allow(SignInEvent).to receive(:new).with(user: user).and_return(mock_event)
        allow(EventNotificationsService).to receive(:broadcast)
      end

      it 'saves the user to session' do
        get :validate, params: params
        expect(controller).to have_received(:save_user_to_session!)
      end

      it 'broadcasts a SignInEvent for the user' do
        get :validate, params: params
        expect(EventNotificationsService).to have_received(:broadcast).with(mock_event)
      end
    end
  end
end
