# "responsible_body_devices_who_to_contact_form"=>{"full_name"=>"", "email_address"=>"", "phone_number"=>""}

require 'rails_helper'

RSpec.describe ResponsibleBody::Devices::WhoToContactController do
  let(:school) { create(:school, :with_headteacher_contact, :with_preorder_information) }
  let(:local_authority) { create(:local_authority, schools: [school]) }
  let(:rb_user) { create(:local_authority_user, responsible_body: local_authority) }
  let(:support_user) { create(:support_user) }
  let(:existing_contact) { school.contacts.first }

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
        expect(existing_contact.role).to eql('headteacher')
      end
    end

    context 'when the contact already exists as a user on another school' do
      let(:existing_user) { create(:school_user) }

      before do
        post :create, params: {
          responsible_body_devices_who_to_contact_form: {
            who_to_contact: 'someone_else',
            full_name: 'different name',
            email_address: existing_user.email_address,
            phone_number: '020 1',
          },
          school_urn: school.urn,
        }
      end

      it 'does not raise an error' do
        expect { response }.not_to raise_error
      end

      it 'displays that the school user has been contacted now' do
        expect(request.flash[:success]).to eq("Saved. We’ve emailed #{existing_user.email_address}")
      end
    end

    context 'when the contact already exists as a user on a responsible body' do
      let(:existing_user) { create(:local_authority_user) }

      before do
        post :create, params: {
          responsible_body_devices_who_to_contact_form: {
            who_to_contact: 'someone_else',
            full_name: 'different name',
            email_address: existing_user.email_address,
            phone_number: '020 1',
          },
          school_urn: school.urn,
        }
      end

      it 'does not raise an error' do
        expect { response }.not_to raise_error
      end

      it 'displays that the school user has been contacted' do
        expect(request.flash[:success]).to eq("Saved. We’ve emailed #{existing_user.email_address}")
      end
    end

    context 'when support user impersonating' do
      before do
        sign_in_as support_user
        impersonate rb_user

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

      it 'returns forbidden' do
        expect(response).to be_forbidden
      end
    end
  end

  describe '#update' do
    context 'when 2 contacts exist' do
      let!(:second_contact) { create(:school_contact, :contact, school: school) }

      def perform_update!
        put :update, params: {
          responsible_body_devices_who_to_contact_form: {
            who_to_contact: 'someone_else', # hidden field
            full_name: 'totally new',
            email_address: 'unique@example.com',
            phone_number: '020 1',
          },
          school_urn: school.urn,
        }
      end

      it 'does not create another contact' do
        expect { perform_update! }.not_to change(SchoolContact, :count)
      end

      it 'updates the second contact' do
        perform_update!
        second_contact.reload

        expect(second_contact.full_name).to eql('totally new')
        expect(second_contact.email_address).to eql('unique@example.com')
        expect(second_contact.phone_number).to eql('020 1')
      end
    end

    context 'when support user impersonating' do
      before do
        sign_in_as support_user
        impersonate rb_user

        put :update, params: {
          responsible_body_devices_who_to_contact_form: {
            who_to_contact: 'someone_else', # hidden field
            full_name: 'totally new',
            email_address: 'unique@example.com',
            phone_number: '020 1',
          },
          school_urn: school.urn,
        }
      end

      it 'returns forbidden' do
        expect(response).to be_forbidden
      end
    end
  end
end
