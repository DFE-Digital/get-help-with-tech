require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::SchoolsController do
  let(:user) { create(:trust_user) }
  let(:rb) { user.responsible_body }
  let!(:closed_school) { create(:school, status: 'closed', responsible_body: rb) }

  before do
    sign_in_as user
  end

  describe '#index' do
    context 'RB with virtual cap' do
      before do
        user.responsible_body.update!(vcap: true, default_who_will_order_devices_for_schools: :responsible_body)
        get :index
      end

      specify { expect(assigns(:vcap)).to be true }
    end

    context 'RB without virtual cap' do
      before { get :index }

      specify { expect(assigns(:vcap)).to be false }
    end

    it 'excludes closed schools' do
      get :index
      expect(assigns(:schools)[:ordering_schools]).not_to include(closed_school)
      expect(assigns(:schools)[:specific_circumstances_schools]).not_to include(closed_school)
      expect(assigns(:schools)[:fully_open_schools]).not_to include(closed_school)
    end
  end
end
