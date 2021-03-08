require 'rails_helper'

RSpec.describe School::WelcomeWizardController do
  let(:school_user) { create(:school_user) }
  let(:school) { school_user.school }

  describe '#next_step' do
    context 'when support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate school_user
      end

      it 'returns forbidden' do
        patch :next_step, params: { urn: school.urn }
        expect(response).to be_forbidden
      end
    end
  end
end
