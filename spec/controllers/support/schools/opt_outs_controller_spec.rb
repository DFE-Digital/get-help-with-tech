require 'rails_helper'

RSpec.describe Support::Schools::OptOutsController do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }

  before do
    sign_in_as support_user
  end

  describe '#edit' do
    it 'works' do
      get :edit, params: { school_urn: school.urn }
      expect(response).to be_successful
    end
  end

  describe '#update' do
    context 'opting out' do
      it 'sets school#opted_out_of_comms_at with timestamp' do
        post :update, params: { school_urn: school.urn, school: { opt_out: '1' } }
        expect(school.reload.opted_out_of_comms_at).to be_within(10.seconds).of(Time.zone.now)
      end

      it 'redirects back to school' do
        post :update, params: { school_urn: school.urn, school: { opt_out: '1' } }
        expect(response).to redirect_to(support_school_path(school))
      end

      it 'sets flash success' do
        post :update, params: { school_urn: school.urn, school: { opt_out: '1' } }
        expect(flash[:success]).to be_present
      end
    end

    context 'opting back in' do
      let(:school) { create(:school, opted_out_of_comms_at: 1.day.ago) }

      it 'sets nullifies school#opted_out_of_comms_at' do
        post :update, params: { school_urn: school.urn, school: { opt_out: '0' } }
        expect(school.reload.opted_out_of_comms_at).to be_nil
      end

      it 'redirects back to school' do
        post :update, params: { school_urn: school.urn, school: { opt_out: '0' } }
        expect(response).to redirect_to(support_school_path(school))
      end

      it 'sets flash success' do
        post :update, params: { school_urn: school.urn, school: { opt_out: '1' } }
        expect(flash[:success]).to be_present
      end
    end
  end
end
