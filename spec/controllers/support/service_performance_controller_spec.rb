require 'rails_helper'

RSpec.describe Support::ServicePerformanceController, type: :controller do
  describe 'index' do
    it 'displays the service performance when authenticated as a DfE user' do
      sign_in_as create(:dfe_user)

      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'is forbidden for MNO users' do
      expect { get :index }.to be_forbidden_for(create(:mno_user))
    end

    it 'is forbidden for responsible body users' do
      expect { get :index }.to be_forbidden_for(create(:trust_user))
    end

    it 'redirects to / for unauthenticated users' do
      get :index

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
