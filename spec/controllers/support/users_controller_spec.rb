require 'rails_helper'

RSpec.describe Support::UsersController, type: :controller do
  describe 'create' do
    it 'is forbidden for MNO users' do
      sign_in_as create(:mno_user)

      post :create, params: { responsible_body_id: 1, user: { some: 'data' } }

      expect(response).to have_http_status(:forbidden)
    end

    it 'is forbidden for responsible body users' do
      sign_in_as create(:trust_user)

      post :create, params: { responsible_body_id: 1, user: { some: 'data' } }

      expect(response).to have_http_status(:forbidden)
    end

    it 'redirects to / for unauthenticated users' do
      post :create, params: { responsible_body_id: 1, user: { some: 'data' } }

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
