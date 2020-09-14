require 'rails_helper'

RSpec.describe Support::Devices::SchoolsController, type: :controller do
  let(:school) { create(:school) }

  describe 'show' do
    it 'is forbidden for MNO users' do
      sign_in_as create(:mno_user)

      get :show, params: { urn: school.urn }

      expect(response).to have_http_status(:forbidden)
    end

    it 'is forbidden for responsible body users' do
      sign_in_as create(:trust_user)

      get :show, params: { urn: school.urn }

      expect(response).to have_http_status(:forbidden)
    end

    it 'redirects to / for unauthenticated users' do
      get :show, params: { urn: school.urn }

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
