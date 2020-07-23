require 'rails_helper'

RSpec.describe SignInTokensController, type: :controller do
  let(:user) { create(:local_authority_user, :who_has_requested_a_magic_link) }

  describe 'destroy' do
    it 'clears the token when the user is signed in' do
      sign_in_as user

      post :destroy

      expect(user.reload.sign_in_token).to be_nil
    end

    it 'redirects to the sign-in path if the user is not signed in' do
      post :destroy

      expect(user.reload.sign_in_token).not_to be_nil
      expect(response).to redirect_to(sign_in_path)
    end
  end
end
