require 'rails_helper'

RSpec.describe OrdersController do
  describe '#index' do
    let!(:orders) { create_list(:computacenter_order, 2) }

    context 'not logged in' do
      it 'redirects to log in' do
        get :index
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context 'school A' do
      let(:school_a) { create(:school, :with_orders) }
      let(:school_a_user) { create(:school_user, schools: [school_a]) }

      before { sign_in_as school_a_user }

      it 'shows index of orders belonging to that school' do
        get :index
        expect(response).to be_successful
        expect(assigns(:orders)).to contain_exactly(*school_a.orders)
        expect(response).to render_template(:index)
      end
    end

    context 'RB A' do
      let(:rb_a) { create(:local_authority, :with_orders) }
      let(:rb_a_user) { create(:local_authority_user, responsible_body: rb_a) }

      before { sign_in_as rb_a_user }

      it 'shows index of orders belonging to that RB' do
        get :index
        expect(response).to be_successful
        expect(assigns(:orders)).to contain_exactly(*rb_a.orders)
        expect(response).to render_template(:index)
      end
    end

    context 'support user' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
      end

      it 'shows index of all orders' do
        get :index
        expect(response).to be_successful
        expect(assigns(:orders)).to contain_exactly(*orders)
        expect(response).to render_template(:index)
      end
    end

    context 'computacenter user' do
      let(:computacenter_user) { create(:computacenter_user) }

      before { sign_in_as computacenter_user }

      it 'shows index of all orders' do
        get :index
        expect(response).to be_successful
        expect(assigns(:orders)).to contain_exactly(*orders)
        expect(response).to render_template(:index)
      end
    end
  end
end
