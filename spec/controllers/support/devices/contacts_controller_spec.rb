require 'rails_helper'

RSpec.describe Support::Devices::ContactsController do
  include Rails.application.routes.url_helpers

  let(:school) { create(:school, :with_headteacher_contact, :with_preorder_information) }
  let(:contact) { school.contacts.first }
  let(:support_user) { create(:support_user) }

  before do
    sign_in_as support_user
  end

  describe '#edit' do
    it 'responds successfully' do
      get :edit, params: { school_urn: school.urn, id: contact.id }
      expect(response).to be_successful
    end
  end

  describe '#update' do
    let(:full_name) { 'new name' }

    before do
      put :update, params: {
        school_urn: school.urn,
        id: contact.id,
        school_contact: {
          full_name: full_name,
          email_address: 'new.email@example.com',
          phone_number: '020 07275930',
        },
      }
    end

    it 'updates contact details' do
      contact.reload

      expect(contact.full_name).to eql('new name')
      expect(contact.email_address).to eql('new.email@example.com')
      expect(contact.phone_number).to eql('020 07275930')
    end

    it 'redirects user back to school' do
      expect(response).to redirect_to(support_devices_school_path(school.urn))
    end

    it 'populates success flash message' do
      expect(flash[:success]).to be_present
    end

    context 'sad path' do
      let(:full_name) { '' }

      it 'renders form again' do
        expect(contact).to render_template('support/devices/contacts/edit')
      end
    end
  end

  describe '#set_as_school_contact' do
    let(:other_contact) { create(:school_contact, school: school) }

    before do
      put :set_as_school_contact, params: {
        school_urn: school.urn,
        id: other_contact.id,
      }
    end

    it 'updates current school contact' do
      expect(school.preorder_information.reload.school_contact).to eql(other_contact)
    end
  end
end
