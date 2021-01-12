require 'rails_helper'

RSpec.describe Support::Users::SchoolsController, type: :controller do
  let(:user) { create(:support_user) }
  let(:trust_user) { create(:trust_user, full_name: 'Jane Smith') }

  before do
    sign_in_as user
  end

  describe '#new' do
    it 'validates that the name or URN param is 3 characters or longer' do
      get :new, params: { user_id: trust_user.id, support_school_suggestion_form: { name_or_urn: 'ab' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:search_again)
    end
  end

  describe '#create' do
    let(:school_to_add) { create(:school, name: 'ABC school') }
    let(:another_school) { create(:school, name: 'DEF school') }

    it 'grants user access to the school when the support agent provides a URN via the text box (no JS)' do
      get :create, params: {
        user_id: trust_user.id,
        support_school_suggestion_form: { name_or_urn: school_to_add.urn.to_s },
      }

      expect(trust_user.schools.reload).to include(school_to_add)
      expect(response).to redirect_to(support_user_path(trust_user))
      expect(flash[:success]).to eq('Jane Smith is now associated with ABC school')
    end

    it 'grants user access to the school when the support agent picks a school via the JS-powered autocomplete' do
      get :create, params: {
        user_id: trust_user.id,
        support_school_suggestion_form: { school_urn: school_to_add.urn },
      }

      expect(trust_user.schools.reload).to include(school_to_add)
      expect(response).to redirect_to(support_user_path(trust_user))
      expect(flash[:success]).to eq('Jane Smith is now associated with ABC school')
    end

    it 'grants user access to the school when the support agent types in the partial name and there is an exact match' do
      school_to_add
      another_school

      get :create, params: {
        user_id: trust_user.id,
        support_school_suggestion_form: { name_or_urn: 'ABC' },
      }

      expect(trust_user.schools.reload).to include(school_to_add)
      expect(response).to redirect_to(support_user_path(trust_user))
      expect(flash[:success]).to eq('Jane Smith is now associated with ABC school')
    end

    it 'redirects to :new when the support agent types in the partial name and there are multiple matches' do
      school_to_add
      another_school

      get :create, params: {
        user_id: trust_user.id,
        support_school_suggestion_form: { name_or_urn: 'school' },
      }

      expect(response).to redirect_to(new_support_user_school_path(trust_user, 'support_school_suggestion_form[name_or_urn]' => 'school'))
    end

    it 'prompts to search again if the support agent enters a school name that is too short' do
      get :create, params: {
        user_id: trust_user.id,
        support_school_suggestion_form: { name_or_urn: 'ab' },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:search_again)
    end
  end
end
