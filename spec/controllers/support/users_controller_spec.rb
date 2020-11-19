require 'rails_helper'

RSpec.describe Support::UsersController do
  let(:support_user) { create(:support_user) }
  let(:user_who_has_seen_privacy_notice) { create(:school_user, :has_seen_privacy_notice, full_name: 'Jane Smith') }
  let(:user_who_has_not_seen_privacy_notice) { create(:school_user, :has_not_seen_privacy_notice, full_name: 'John Smith') }

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
    end

    it 'returns all matching school and RB users for support users' do
      sign_in_as support_user
      post :results, params: { support_user_search_form: { email_address_or_full_name: 'Smith' } }

      expect(assigns[:results]).to contain_exactly(user_who_has_seen_privacy_notice,  user_who_has_not_seen_privacy_notice)
    end

    it 'returns all matching school and RB users who have seen the privacy notice for Computacenter users' do
      sign_in_as create(:computacenter_user)
      post :results, params: { support_user_search_form: { email_address_or_full_name: 'Smith' } }

      expect(assigns[:results]).to contain_exactly(user_who_has_seen_privacy_notice)
    end
  end
end
