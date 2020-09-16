# "responsible_body_devices_who_to_contact_form"=>{"full_name"=>"", "email_address"=>"", "phone_number"=>""}

require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::WhoToContactController do
  let(:school) { create(:school, :with_headteacher_contact, :with_preorder_information) }
  let(:local_authority) { create(:local_authority, schools: [school], in_devices_pilot: true) }
  let(:rb_user) { create(:local_authority_user, responsible_body: local_authority) }

  before do
    sign_in_as rb_user
  end

  describe '#create' do
    context "when user doesn't select anything" do
      before do
        post :create, params: {
          responsible_body_devices_who_to_contact_form: {
            full_name: '',
            email_address: '',
            phone_number: '',
          },
          school_urn: school.urn,
        }
      end

      it 'displays errors' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when contact exists and updating the same email' do
      let(:existing_contact) { school.contacts.first }

      before do
        post :create, params: {
          responsible_body_devices_who_to_contact_form: {
            who_to_contact: 'someone_else',
            full_name: 'different name',
            email_address: existing_contact.email_address,
            phone_number: '020 1',
          },
          school_urn: school.urn,
        }
      end

      it 'does not raise an error' do
        expect { response }.not_to raise_error
      end

      it 'does not create a new contact' do
        expect { response }.not_to change(SchoolContact, :count)
      end

      it 'updates the existing contact' do
        existing_contact.reload

        expect(existing_contact.full_name).to eql('different name')
        expect(existing_contact.phone_number).to eql('020 1')
      end
    end
  end
end
