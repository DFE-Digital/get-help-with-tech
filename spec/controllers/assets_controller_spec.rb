require 'rails_helper'

RSpec.describe AssetsController do
  describe '#index' do
    before { allow(Asset).to receive(:owned_by) }

    context 'school A' do
      let(:school_a) { create(:school) }
      let(:school_a_user) { create(:school_user, schools: [school_a]) }

      before { sign_in_as school_a_user }

      it 'shows index of assets belonging to that school' do
        get :index
        expect(response).to be_successful
        expect(Asset).to have_received(:owned_by).with(school_a)
        expect(response).to render_template(:index)
      end
    end

    context 'RB A' do
      let(:rb_a) { create(:local_authority) }
      let(:rb_a_user) { create(:local_authority_user) }

      before do
        rb_a.users = [rb_a_user]
        sign_in_as rb_a_user
      end

      it 'shows index of assets belonging to that RB' do
        get :index
        expect(response).to be_successful
        expect(Asset).to have_received(:owned_by).with(rb_a)
        expect(response).to render_template(:index)
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
