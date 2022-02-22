require 'rails_helper'

RSpec.describe School::HomeController do
  let(:user) { create(:school_user) }
  let(:other_school) { create(:school) }

  before { sign_in_as user }

  describe '#show' do
    context 'when the given URN is one of the users schools' do
      let(:urn) { user.schools.first.urn }

      it 'shows the school home page' do
        get :show, params: { urn: }
        expect(controller).to render_template(:show)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the given URN is valid, but not one of the users schools' do
      it 'responds with a 404' do
        get :show, params: { urn: other_school.urn }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the given URN is not valid' do
      it 'responds with a 404' do
        get :show, params: { urn: 'INVALID' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
