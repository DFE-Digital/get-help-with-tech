require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::ChromebookInformationController do
  describe '#update' do
    context 'when support user impersonating user' do
      let(:support_user) { create(:support_user) }
      let(:rb_user) { create(:trust_user) }
      let(:rb) { rb_user.responsible_body }
      let(:school) { rb.schools.first }

      before do
        create(:school, :with_preorder_information, responsible_body: rb)
        sign_in_as support_user
        impersonate rb_user
      end

      it 'denys the update' do
        put :update, params: { school_urn: school.urn, chromebook_information_form: { will_need_chromebooks: 'no' } }
        expect(response).to be_forbidden
      end
    end
  end
end
