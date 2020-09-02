# "responsible_body_devices_who_to_contact_form"=>{"full_name"=>"", "email_address"=>"", "phone_number"=>""}

require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::WhoToContactController do
  let(:school) { create(:school, :with_headteacher_contact) }
  let(:local_authority) { create(:local_authority, schools: [school], in_devices_pilot: true) }
  let(:rb_user) { create(:local_authority_user, responsible_body: local_authority) }

  before do
    sign_in_as rb_user
  end

  describe '#create' do
    it "displays errors if the user doesn't select anything" do
      post :create, params: {
        responsible_body_devices_who_to_contact_form: { full_name: '', email_address: '', phone_number: '' },
        school_urn: school.urn,
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
