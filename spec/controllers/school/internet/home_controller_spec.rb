require 'rails_helper'

RSpec.describe School::Internet::HomeController do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  before do
    sign_in_as user
  end

  context 'when school mno_feature_flag not active' do
    it 'renders 404' do
      get :show, params: { urn: school.urn }
      expect(response).to be_not_found
    end
  end

  context 'when school mno_feature_flag active' do
    before do
      school.update(mno_feature_flag: true)
    end

    it 'renders 200' do
      get :show, params: { urn: school.urn }
      expect(response).to be_successful
    end
  end
end
