require 'rails_helper'

RSpec.describe School::Internet::HomeController do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  before do
    sign_in_as user
  end

  it 'renders 200' do
    get :show, params: { urn: school.urn }
    expect(response).to be_successful
  end
end
