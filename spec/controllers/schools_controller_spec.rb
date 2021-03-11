require 'rails_helper'

RSpec.describe SchoolsController do
  let(:support_user) { create(:support_user, role: 'third_line') }
  let(:single_school_user) { create(:school_user) }
  let(:multi_school_user) { create(:school_user, schools: [create(:school), create(:school)]) }

  describe '#index' do
    context 'school user has one school' do
      before do
        sign_in_as single_school_user
      end

      it 'redirects to school' do
        get :index
        school = single_school_user.schools.first
        expect(response).to redirect_to("/schools/#{school.urn}")
      end
    end

    context 'school user has multiple schools' do
      before do
        sign_in_as multi_school_user
      end

      it 'shows list of schools' do
        get :index
        expect(response).to be_successful
        expect(assigns(:schools)).to eq(multi_school_user.schools)
      end
    end

    context 'support user impersonating school user with one school' do
      before do
        sign_in_as support_user
        impersonate single_school_user
      end

      it 'shows list of schools' do
        get :index
        school = single_school_user.schools.first
        expect(response).to redirect_to("/schools/#{school.urn}")
      end
    end

    context 'support user impersonating school user multiple schools' do
      before do
        sign_in_as support_user
        impersonate multi_school_user
      end

      it 'shows list of schools' do
        get :index
        expect(response).to be_successful
        expect(assigns(:schools)).to eq(multi_school_user.schools)
      end
    end
  end
end
