require 'rails_helper'

RSpec.describe School::Internet::Mobile::ExtraDataRequestsController, type: :controller do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  context 'when authenticated', with_feature_flags: { school_mno: 'active' } do
    before do
      sign_in_as user
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
