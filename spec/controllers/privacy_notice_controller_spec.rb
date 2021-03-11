require 'rails_helper'

RSpec.describe PrivacyNoticeController do
  let(:support_user) { create(:support_user) }
  let(:school_user) { create(:school_user, :has_not_seen_privacy_notice) }

  describe '#seen' do
    context 'signed in as school user' do
      before do
        sign_in_as school_user
      end

      it 'adds timestamp to privacy_notice_seen_at' do
        post :seen
        expect(school_user.reload.privacy_notice_seen_at).to be_present
      end
    end

    context 'support impersonating school user' do
      before do
        sign_in_as support_user
        impersonate school_user
      end

      it 'does not add timestamp to privacy_notice_seen_at of impersonated user' do
        expect {
          post :seen
        }.not_to(change { school_user.reload.privacy_notice_seen_at })
      end

      it 'does not change their own privacy_notice_seen_at' do
        expect {
          post :seen
        }.not_to(change { support_user.reload.privacy_notice_seen_at })
      end

      it 'returns forbidden' do
        post :seen
        expect(response).to be_forbidden
      end
    end
  end
end
