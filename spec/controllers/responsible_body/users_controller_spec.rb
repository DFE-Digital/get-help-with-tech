require 'rails_helper'

RSpec.describe ResponsibleBody::UsersController do
  let(:local_authority) { create(:local_authority) }
  let(:other_local_authority) { create(:local_authority) }

  let(:rb_user) { create(:local_authority_user, responsible_body: local_authority) }
  let(:rb_user_2) { create(:local_authority_user, responsible_body: local_authority) }
  let(:user_from_other_rb) { create(:local_authority_user, responsible_body: other_local_authority) }

  context 'with the rbs_can_manage_users feature flag set' do
    before do
      FeatureFlag.activate(:rbs_can_manage_users)
    end

    context 'logged in as a RB user' do
      before do
        sign_in_as rb_user
      end

      describe '#edit' do
        it 'lets me access myself' do
          get :edit, params: { id: rb_user.id }
          expect(response).to have_http_status(:ok)
        end

        it 'lets me access another user from the same RB' do
          get :edit, params: { id: rb_user_2.id }
          expect(response).to have_http_status(:ok)
        end

        it 'does not let me access a user from a different RB' do
          get :edit, params: { id: user_from_other_rb.id }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'logged in as non-RB user' do
      let(:mno_user) { create(:mno_user) }

      before do
        sign_in_as mno_user
      end

      it 'does not let me access a responsible_body user' do
        get :edit, params: { id: user_from_other_rb.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
