require 'rails_helper'

RSpec.describe Support::UsersController do
  let(:support_user) { create(:support_user) }
  let(:user_who_has_seen_privacy_notice) { create(:school_user, :has_seen_privacy_notice, full_name: 'Jane Smith') }
  let(:user_who_has_not_seen_privacy_notice) { create(:school_user, :has_not_seen_privacy_notice, full_name: 'John Smith') }
  let(:user_who_is_deleted) { create(:school_user, :has_seen_privacy_notice, :deleted, full_name: 'July Smith') }
  let(:existing_user) { create(:local_authority_user) }

  describe '#search' do
    it 'is successful for support users' do
      expect {
        get :search
      }.to receive_status_ok_for(support_user)
    end

    it 'is successful for computacenter users' do
      expect {
        get :search
      }.to receive_status_ok_for(create(:computacenter_user))
    end
  end

  describe '#results' do
    before do
      user_who_has_seen_privacy_notice
      user_who_has_not_seen_privacy_notice
      user_who_is_deleted
    end

    it 'returns all matching school and RB users for support users' do
      sign_in_as support_user
      post :results, params: { support_user_search_form: { email_address_or_full_name: 'Smith' } }

      expect(assigns[:results]).to contain_exactly(user_who_has_seen_privacy_notice, user_who_has_not_seen_privacy_notice)
    end

    it 'returns all matching school and RB users who have seen the privacy notice for Computacenter users' do
      sign_in_as create(:computacenter_user)
      post :results, params: { support_user_search_form: { email_address_or_full_name: 'Smith' } }

      expect(assigns[:results]).to contain_exactly(user_who_has_seen_privacy_notice)
    end
  end

  describe '#edit' do
    it 'is successful for support users' do
      expect {
        get :edit, params: { id: existing_user.id }
      }.to receive_status_ok_for(support_user)
    end

    it 'is forbidden for computacenter users' do
      expect {
        get :edit, params: { id: existing_user.id }
      }.to be_forbidden_for(create(:computacenter_user))
    end

    it 'does not edit deleted users' do
      sign_in_as support_user

      deleted_user = create(:school_user, :deleted)

      get :edit, params: { id: deleted_user }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '#update' do
    it 'is successful for support users' do
      sign_in_as support_user

      put :update, params: {
        id: existing_user.id,
        user: {
          full_name: 'someone_else',
        },
      }

      expect(response).to redirect_to(support_user_path(existing_user))
    end

    it 'is forbidden for computacenter users' do
      expect {
        put :update, params: {
          id: existing_user.id,
          user: {
            full_name: 'someone_else',
          },
        }
      }.to be_forbidden_for(create(:computacenter_user))
    end
  end

  describe '#destroy' do
    let(:responsible_body) { create(:local_authority) }
    let(:school) { create(:school) }
    let(:existing_user) { create(:local_authority_user) }

    context 'for support users' do
      before do
        sign_in_as support_user
      end

      it 'sets user deleted_at timestamp' do
        delete :destroy, params: { id: existing_user.id }
        expect(existing_user.reload.deleted_at).to be_present
      end

      it 'redirects back to the RB page when called from the responsible body area' do
        delete :destroy, params: { id: existing_user.id, user: { responsible_body_id: responsible_body.id } }
        expect(response).to redirect_to(support_responsible_body_path(responsible_body))
      end

      it 'redirects back to the school page when called from the school area' do
        delete :destroy, params: { id: existing_user.id, user: { school_urn: school.urn } }
        expect(response).to redirect_to(support_school_path(school))
      end
    end

    context 'for computacenter users' do
      it 'is forbidden' do
        expect {
          delete :destroy, params: { id: existing_user.id }
        }.to be_forbidden_for(create(:computacenter_user))
      end
    end
  end
end
