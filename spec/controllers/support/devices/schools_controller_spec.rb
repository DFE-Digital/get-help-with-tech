require 'rails_helper'

RSpec.describe Support::Devices::SchoolsController, type: :controller do
  let(:school) { create(:school, name: 'Alpha School') }

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

  describe 'confirm_invitation' do
    before do
      create(:preorder_information, school: school, school_contact: nil)
      sign_in_as create(:dfe_user)
    end

    context 'when the school has no school contact' do
      it 'redirects back to the school page with an error' do
        get :confirm_invitation, params: { school_urn: school.urn }

        expect(response).to redirect_to(support_devices_school_path(school))
        expect(request.flash[:warning]).to eq('Could not invite Alpha School because the school does not have a contact')
      end
    end
  end
end
