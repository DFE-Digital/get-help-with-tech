require 'rails_helper'

RSpec.describe Support::HomeController do
  let(:support_user) { create(:support_user) }
  let(:cc_user) { create(:computacenter_user) }

  describe '#feature_flags' do
    it 'is accessible to support users' do
      sign_in_as support_user
      get :feature_flags
      expect(response).to be_successful
    end

    it 'is not accessible to CC users' do
      sign_in_as cc_user
      get :feature_flags
      expect(response).not_to be_successful
    end
  end
end
