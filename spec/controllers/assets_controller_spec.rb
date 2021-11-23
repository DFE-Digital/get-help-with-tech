require 'rails_helper'

RSpec.describe AssetsController do
  describe '#index' do
    context 'not logged in' do
      it 'redirects to log in' do
        get :index
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context 'school A' do
      let(:school_a) { create(:school) }
      let(:school_b) { create(:school) }
      let(:school_a_user) { create(:school_user, schools: [school_a]) }
      let!(:school_a_asset) { create(:asset, location_cc_ship_to_account: school_a.computacenter_reference) }
      let!(:school_b_asset) { create(:asset, location_cc_ship_to_account: school_b.computacenter_reference) }

      before { sign_in_as school_a_user }

      it 'shows index of assets belonging to that school' do
        get :index
        expect(response).to be_successful
        expect(assigns(:assets)).to contain_exactly(school_a_asset)
        expect(assigns(:assets)).not_to include(school_b_asset)
        expect(response).to render_template(:index)
      end
    end

    context 'RB A' do
      let(:rb_a) { create(:local_authority) }
      let(:rb_b) { create(:local_authority) }
      let!(:rb_a_asset) { create(:asset, department_sold_to_id: rb_a.computacenter_reference) }
      let!(:rb_b_asset) { create(:asset, department_sold_to_id: rb_b.computacenter_reference) }
      let(:rb_a_user) { create(:local_authority_user) }

      before do
        rb_a.users = [rb_a_user]
        sign_in_as rb_a_user
      end

      it 'shows index of assets belonging to that RB' do
        get :index
        expect(response).to be_successful
        expect(assigns(:assets)).to contain_exactly(rb_a_asset)
        expect(assigns(:assets)).not_to include(rb_b_asset)
        expect(response).to render_template(:index)
      end
    end

    context 'support user' do
      let(:school) { create(:school) }
      let(:school_user) { create(:school_user, schools: [school]) }
      let(:support_user) { create(:support_user) }
      let!(:school_asset) { create(:asset, location_cc_ship_to_account: school.computacenter_reference) }

      before { sign_in_as support_user }

      context 'logged in as themselves' do
        it 'shows index with no assets' do
          get :index
          expect(response).to be_successful
          expect(assigns(:assets)).to be_empty
          expect(response).to render_template(:index)
        end
      end

      context 'impersonating user' do
        before { impersonate school_user }

        it 'shows index with school assets' do
          get :index
          expect(response).to be_successful
          expect(assigns(:assets)).to contain_exactly(school_asset)
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'search' do
      context 'logged in' do
        let(:support_user) { create(:support_user) }

        before do
          allow(Asset).to receive(:search_by_serial_numbers)

          sign_in_as support_user
        end

        it 'shows the search results' do
          get :index, params: { serial_number: '1234' }

          expect(response).to be_successful
          expect(Asset).to have_received(:search_by_serial_numbers).with(%w[1234])
          expect(response).to render_template(:index)
        end
      end

      context 'multiple serial numbers' do
        let(:support_user) { create(:support_user) }
        let(:non_support_user) { create(:school_user) }

        before { allow(Asset).to receive(:search_by_serial_numbers) }

        context 'non-support user' do
          before { sign_in_as non_support_user }

          it 'assumes search is for only one serial number' do
            get :index, params: { serial_number: '1,2' }

            expect(response).to be_successful
            expect(Asset).to have_received(:search_by_serial_numbers).with(['1,2'])
            expect(response).to render_template(:index)
          end
        end

        context 'support user' do
          before { sign_in_as support_user }

          it 'shows the search results' do
            get :index, params: { serial_number: '1,2' }

            expect(response).to be_successful
            expect(Asset).to have_received(:search_by_serial_numbers).with(%w[1 2])
            expect(response).to render_template(:index)
          end
        end
      end
    end
  end

  describe 'CSV format' do
    let!(:school) { create(:school) }
    let!(:school_user) { create(:school_user, schools: [school]) }
    let!(:support_user) { create(:support_user) }
    let!(:asset_1) { create(:asset, :never_viewed, location_cc_ship_to_account: school.computacenter_reference) }
    let!(:asset_2) { create(:asset, :never_viewed, location_cc_ship_to_account: school.computacenter_reference) }
    let!(:other_asset) { create(:asset, :never_viewed) }

    context 'user counts as viewer' do
      before { sign_in_as school_user }

      context 'with search' do
        before { get :index, format: :csv, params: { serial_number: other_asset.serial_number } }

        it 'marks the downloaded found asset as viewed' do
          [asset_1, asset_2, other_asset].each(&:reload)

          expect(asset_1).not_to be_viewed
          expect(asset_2).not_to be_viewed
          expect(other_asset).to be_viewed
        end
      end

      context 'without search' do
        it 'marks the index assets as viewed' do
          get :index, format: :csv

          [asset_1, asset_2, other_asset].each(&:reload)

          expect([asset_1, asset_2]).to all be_viewed
          expect(other_asset).not_to be_viewed
        end
      end
    end

    context 'user who does not count as viewer impersonating user who does' do
      before do
        sign_in_as support_user
        impersonate school_user
      end

      it 'does not mark downloaded CSV assets as viewed' do
        get :index, format: :csv

        [asset_1, asset_2, other_asset].each(&:reload)

        expect(asset_1).not_to be_viewed
        expect(asset_2).not_to be_viewed
        expect(other_asset).not_to be_viewed
      end
    end
  end

  describe '#show' do
    context 'not logged in' do
      let(:asset) { create(:asset) }

      it 'redirects to log in' do
        get :show, params: { uid: asset.to_param }
        expect(response).to redirect_to(sign_in_path)
      end
    end

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
            get :show, params: { uid: asset.to_param }
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
            get :show, params: { uid: asset.to_param }
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
          get :show, params: { uid: asset.to_param }

          expect(asset.first_viewed_at).to eq(first_view_timestamp)
          expect(asset.first_viewed_at).not_to eq(second_view_timestamp)
        end
      end
    end
  end

  describe '#bios_unlocker' do
    context 'non signed-in user' do
      before { get :bios_unlocker, params: { uid: '1-123' } }

      specify { expect(response).to redirect_to(sign_in_path) }
    end

    context 'signed-in user' do
      let(:user) { create(:support_user) }
      let(:asset) { create(:asset) }

      before do
        sign_in_as user
        get :bios_unlocker, params: { uid: asset.to_param }
      end

      specify { expect(response).to be_successful }

      it 'return the BIOS_Unlocker.exe file' do
        expect(response.stream.to_path).to eq(Rails.root.join('private/BIOS_Unlocker.exe'))
      end
    end
  end
end
