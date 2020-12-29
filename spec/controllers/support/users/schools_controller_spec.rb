require 'rails_helper'

RSpec.describe Support::Users::SchoolsController, type: :controller do
  let(:user) { create(:support_user) }
  let(:trust_user) { create(:trust_user) }

  before do
    sign_in_as user
  end

  describe '#new' do
    it 'validates that the name or URN param is 3 characters or longer' do
      get :new, params: { user_id: trust_user.id, support_new_user_school_form: { name_or_urn: 'ab' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:search_again)
    end
  end
end
