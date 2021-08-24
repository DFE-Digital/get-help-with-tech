require 'rails_helper'

RSpec.describe AssetsController do
  describe '#index' do
    before { allow(Asset).to receive(:owned_by) }

    context 'not logged in' do
      it 'redirects to log in' do
        get :index
        expect(response).to redirect_to(sign_in_path)
      end
    end

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

    context 'support user' do
      let(:support_user) { create(:support_user) }

      before { sign_in_as support_user }

      it 'shows index with no assets' do
        get :index
        expect(response).to be_successful
        expect(Asset).to have_received(:owned_by).with(nil)
        expect(response).to render_template(:index)
      end
    end
  end

  describe '#show' do
    context 'first view' do
      context 'school or RB user' do
        let(:school) { create(:school) }
        let(:school_user) { create(:school_user, schools: [school]) }
        let(:asset) { create(:asset, :never_viewed) }
        let(:first_view_timestamp) { Time.zone.parse('1 Jan 2020 09:00') }

        before { sign_in_as school_user }

        it 'records the time of the first view' do
          expect(asset).not_to be_viewed
          expect(asset.first_viewed_at).to be_nil

          Timecop.freeze(first_view_timestamp) do
            get :show, params: { id: asset.id }
            asset.reload

            expect(asset).to be_viewed
            expect(asset.first_viewed_at).to eq(first_view_timestamp)
          end

          expect(assigns(:asset)).to eq(asset)
          expect(response).to render_template(:show)
        end
      end

      context 'support user' do
        let(:support_user) { create(:support_user) }
        let(:asset) { create(:asset, :never_viewed) }
        let(:first_view_timestamp) { Time.zone.parse('1 Jan 2020 09:00') }

        before { sign_in_as support_user }

        it 'does not record the time of the first view' do
          expect(asset).not_to be_viewed
          expect(asset.first_viewed_at).to be_nil

          Timecop.freeze(first_view_timestamp) do
            get :show, params: { id: asset.id }
            asset.reload

            expect(asset).not_to be_viewed
          end
        end
      end
    end

    context 'second view' do
      let(:asset) { create(:asset, :viewed) }
      let(:first_view_timestamp) { asset.first_viewed_at }
      let(:second_view_timestamp) { 1.minute.ago }

      it 'keeps the time of the first view' do
        Timecop.freeze(second_view_timestamp) do
          get :show, params: { id: asset.id }

          expect(asset.first_viewed_at).to eq(first_view_timestamp)
          expect(asset.first_viewed_at).not_to eq(second_view_timestamp)
        end
      end
    end
  end

  describe '#search' do
    let(:support_user) { create(:support_user) }

    before do
      allow(Asset).to receive(:search_by_serial_number)

      sign_in_as support_user
    end

    it 'shows the search results' do
      post :search, params: { serial_number: '1234' }

      expect(response).to be_successful
      expect(Asset).to have_received(:search_by_serial_number).with('1234')
      expect(response).to render_template(:index)
    end
  end
end
