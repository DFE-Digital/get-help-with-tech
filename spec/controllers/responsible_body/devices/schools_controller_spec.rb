require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::SchoolsController do
  let(:user) { create(:trust_user) }
  let(:rb) { user.responsible_body }
  let!(:closed_school) { create(:school, status: 'closed', responsible_body: rb) }

  before do
    sign_in_as user
  end

  describe '#index' do
    it 'excludes closed schools' do
      get :index
      expect(assigns(:schools)[:ordering_schools]).not_to include(closed_school)
      expect(assigns(:schools)[:specific_circumstances_schools]).not_to include(closed_school)
      expect(assigns(:schools)[:fully_open_schools]).not_to include(closed_school)
    end
  end
end
