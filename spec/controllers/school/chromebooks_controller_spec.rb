require 'rails_helper'

RSpec.describe School::ChromebooksController do
  let(:school_user) { create(:school_user) }
  let(:school) { school_user.school }

  describe '#update' do
    context 'when support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate school_user
      end

      it 'returns forbidden' do
        put :update, params: { urn: school.urn, chromebook_information_form: { will_need_chromebooks: 'no' } }
        expect(response).to be_forbidden
      end
    end
  end
end
