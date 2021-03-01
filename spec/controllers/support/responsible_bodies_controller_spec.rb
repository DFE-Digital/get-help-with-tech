require 'rails_helper'

RSpec.describe Support::ResponsibleBodiesController, type: :controller do
  describe '#index' do
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

  describe '#show' do
    let(:user) { create(:support_user) }
    let!(:trust_user) { create(:trust_user) }
    let!(:rb) { trust_user.responsible_body }
    let!(:school) { create(:school, responsible_body: rb) }
    let!(:closed_school) { create(:school, responsible_body: rb, status: :closed) }

    before do
      sign_in_as user
    end

    it 'includes open schools in the schools collection' do
      get :show, params: { id: rb.id }
      expect(assigns(:schools)).to match_array [school]
    end

    it 'includes closed schools in the closed_schools collection' do
      get :show, params: { id: rb.id }
      expect(assigns(:closed_schools)).to match_array [closed_school]
    end
  end
end
