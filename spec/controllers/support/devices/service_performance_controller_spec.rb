require 'rails_helper'

RSpec.describe Support::Devices::ServicePerformanceController, type: :controller do
  describe 'index' do
    it 'displays the service performance when authenticated as a DfE user' do
      sign_in_as create(:dfe_user)

      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'is forbidden for MNO users' do
      sign_in_as create(:mno_user)

      get :index

      expect(response).to have_http_status(:forbidden)
    end

    it 'is forbidden for responsible body users' do
      sign_in_as create(:trust_user)

      get :index

      expect(response).to have_http_status(:forbidden)
    end

    it 'redirects to / for unauthenticated users' do
      get :index

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
