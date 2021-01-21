require 'rails_helper'

RSpec.describe Support::SchoolsController, type: :controller do
  let(:school) { create(:school, name: 'Alpha School') }
  let(:another_school) { create(:school, name: 'Beta School') }
  let(:support_user) { create(:support_user) }

  describe '#search' do
    before do
      sign_in_as support_user
    end

    it 'responds successfully' do
      get :search
      expect(response).to be_successful
    end
  end

  describe '#results' do
    before do
      sign_in_as support_user
    end

    it 'renders HTML results when POSTing' do
      post :results, params: { school_search_form: { identifiers: "#{school.urn}\r\n#{another_school.urn}" } }

      expect(response).to be_successful
      expect(response).to render_template('results')
    end

    context 'GET (from a JS autocomplete)' do
      it 'returns JSON results for a valid query string' do
        # ensure schools exist
        school
        another_school

        get :results, params: { query: 'Alpha' }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq 'application/json; charset=utf-8'

        body = JSON.parse(response.body)
        expect(body).to eq([{
          'id' => school.id,
          'name' => school.name,
          'urn' => school.urn,
          'town' => school.town,
          'postcode' => school.postcode,
        }])
      end

      it 'returns an error when the query string is too short' do
        get :results, params: { query: 'aa' }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq 'application/json; charset=utf-8'

        body = JSON.parse(response.body)
        expect(body).to eq({
          'errors' => ["'Name or urn' Enter a school name that is at least 3 characters"],
        })
      end
    end
  end

  describe 'show' do
    it 'is forbidden for MNO users' do
      expect { get :show, params: { urn: school.urn } }.to be_forbidden_for(create(:mno_user))
    end

    it 'is forbidden for responsible body users' do
      expect { get :show, params: { urn: school.urn } }.to be_forbidden_for(create(:trust_user))
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

        expect(response).to redirect_to(support_school_path(school))
        expect(request.flash[:warning]).to eq('Could not invite Alpha School because the school does not have a contact')
      end
    end
  end

  describe 'history' do
    before do
      sign_in_as create(:dfe_user)
    end

    it 'responds successfully' do
      get :history, params: { school_urn: school.urn }
      expect(response).to be_successful
    end

    it 'responds successfully with each view' do
      %w[school std_device coms_device std_device_pool coms_device_pool caps ordered].each do |view|
        get :history, params: { school_urn: school.urn, view: view }
        expect(response).to be_successful
      end
    end
  end
end
