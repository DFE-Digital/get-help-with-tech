require 'rails_helper'

RSpec.describe AssetsController do
  describe '#index' do
    context 'school A' do
      let(:school_a) { create(:school) }
      let(:school_b) { create(:school) }
      let(:school_a_user) { create(:school_user, schools: [school_a]) }
      let(:school_a_asset1) { create(:asset, location_id: school_a.id) }
      let(:school_a_asset2) { create(:asset, location_id: school_a.id) }
      let(:school_b_asset) { create(:asset, location_id: school_b.id) }

      before { sign_in_as school_a_user }

      it 'shows index of assets belonging to that school' do
        get :index
        expect(response).to be_successful
        expect(assigns(:assets)).to contain_exactly(school_a_asset1, school_a_asset2)
        expect(assigns(:assets)).not_to include(school_b_asset)
      end
    end

    context 'RB A' do
      let(:rb_a) { create(:local_authority) }
      let(:rb_b) { create(:local_authority) }
      let(:rb_a_user) { create(:local_authority_user) }
      let(:rb_a_asset1) { create(:asset, department_sold_to_id: rb_a.id) }
      let(:rb_a_asset2) { create(:asset, department_sold_to_id: rb_a.id) }
      let(:rb_b_asset) { create(:asset, department_sold_to_id: rb_b.id) }

      before do
        rb_a.users = [rb_a_user]
        sign_in_as rb_a_user
      end

      it 'shows index of assets belonging to that RB' do
        get :index
        expect(response).to be_successful
        expect(assigns(:assets)).to contain_exactly(rb_a_asset1, rb_a_asset2)
        expect(assigns(:assets)).not_to include(rb_b_asset)
      end
    end
  end

  describe '#show' do
    let(:asset) { create(:asset) }

    before { get :show, params: { id: asset.id } }

    specify { expect(assigns(:asset)).to eq(asset) }
    specify { expect(response).to render_template(:show) }
  end
end
