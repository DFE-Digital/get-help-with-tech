require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::OrdersController do
  let(:user) { create(:trust_user) }
  let(:rb) { user.responsible_body }

  before do
    sign_in_as user
  end

  describe '#show' do
    let!(:closed_school) { create(:school, responsible_body: rb, status: :closed, order_state: :can_order) }

    before do
      create(:preorder_information, school: closed_school, who_will_order_devices: :responsible_body)
    end

    it 'excludes closed schools' do
      get :show, params: { id: rb.id }
      expect(assigns(:schools)).to be_nil
    end
  end
end
