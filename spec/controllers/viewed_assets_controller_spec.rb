require 'rails_helper'

describe ViewedAssetsController, type: :controller do
  let(:support_user) { create(:support_user) }

  describe '#new' do
    before do
      sign_in_as support_user
      get :new
    end

    specify { expect(assigns(:title)).to eq('Viewed devices CSV download') }
  end

  describe '#index' do
    context 'not logged in' do
      it 'redirects to log in' do
        get :index, format: :csv
        expect(response).not_to be_successful
      end
    end

    context 'logged in' do
      context 'start before end' do
        let(:start_period_string) { '20 September 2020 09:00' }
        let(:end_period_string) { '20 September 2020 10:00' }
        let!(:first_viewed_during) { create(:asset, first_viewed_at: Time.zone.parse('20 September 2020 09:01"')) }

        before do
          create(:asset, first_viewed_at: Time.zone.parse('20 September 2020 08:59'))
          create(:asset, first_viewed_at: Time.zone.parse('20 September 2020 10:01'))

          sign_in_as support_user
          get :index, params: { datetime_period: { start_at_string: start_period_string, end_at_string: end_period_string } }, format: :csv
        end

        specify { expect(assigns(:filename)).to eq('assets_first_viewed_during_2020-09-20T09:00--2020-09-20T10:00.csv') }
        specify { expect(assigns(:viewed_assets)).to contain_exactly(first_viewed_during) }
      end

      context 'end before start' do
        let(:start_period_string) { '20 September 2020 10:00' }
        let(:end_period_string) { '20 September 2020 09:00' }

        before do
          sign_in_as support_user
          get :index, params: { datetime_period: { start_at_string: start_period_string, end_at_string: end_period_string } }, format: :csv
        end

        specify { expect(assigns(:period)).to be_nil }
      end

      context 'zero period' do
        let(:datetime_string) { '20 September 2020 10:00' }

        before do
          sign_in_as support_user
          get :index, params: { datetime_period: { start_at_string: datetime_string, end_at_string: datetime_string } }, format: :csv
        end

        specify { expect(assigns(:period)).to be_nil }
      end
    end
  end
end
