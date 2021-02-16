require 'rails_helper'

RSpec.describe School::Internet::Mobile::ExtraDataRequestsController, type: :controller do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  context 'when authenticated' do
    before do
      sign_in_as user
    end

    describe '#index' do
      it 'shows the previous mobile data requests page' do
        get :index, params: { urn: school.urn }
        expect(controller).to render_template(:index)
        expect(response).to have_http_status(:ok)
      end
    end

    describe '#guidance' do
      it 'shows the request data for mobile devices guidance page' do
        get :guidance, params: { urn: school.urn }
        expect(controller).to render_template(:guidance)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'submitting spreadsheet choice' do
      it 'redirects to bulk requests' do
        request_data = {
          urn: school.urn,
          extra_mobile_data_submission_form: {
            submission_type: 'bulk',
          },
          commit: 'Continue',
        }
        get :new, params: request_data
        expect(response).to redirect_to(new_internet_mobile_bulk_request_path(school))
      end
    end

    describe 'submitting manual choice' do
      it 'redirects to the manual requests' do
        request_data = {
          urn: school.urn,
          extra_mobile_data_submission_form: {
            submission_type: 'manual',
          },
          commit: 'Continue',
        }
        get :new, params: request_data
        expect(response).to redirect_to(new_internet_mobile_manual_request_path(school))
      end
    end
  end
end
