require 'rails_helper'

RSpec.describe KeyContactsImporter, type: :model do
  describe 'importing key contacts' do
    let(:filename) { Rails.root.join('tmp/key_contact_data.csv') }
    let(:responsible_body) { create(:local_authority) }

    context 'when a contact does not already exist' do
      let(:attrs) do
        {
          id: responsible_body.id,
          email_address: 'walter.carp@example.com',
          full_name: 'Walter Carp',
          telephone: '0123456789',
        }
      end

      before do
        create_key_contacts_csv_file(filename, [attrs])
        @service = described_class.new(KeyContactDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'creates a new User record' do
        expect {
          @service.import_contacts
        }.to change { User.count }.by(1)
      end

      it 'sets the correct values on the User record' do
        @service.import_contacts
        expect(User.last).to have_attributes(
          email_address: 'walter.carp@example.com',
          full_name: 'Walter Carp',
          telephone: '0123456789',
        )
        expect(User.last.responsible_bodies).to eq([responsible_body])
      end

      it 'assigns the contact as the key contact for the responsible body' do
        @service.import_contacts
        expect(responsible_body.reload.key_contact_id).to eq(User.last.id)
      end

      it 'flags the responsible body as in the devices pilot' do
        @service.import_contacts
        expect(responsible_body.reload.in_devices_pilot?).to be true
      end
    end

    context 'when a contact already exists' do
      let(:contact) { create(:local_authority_user, responsible_bodies: [responsible_body]) }

      let(:attrs) do
        {
          id: responsible_body.id,
          full_name: 'Katie Redshaw',
          email_address: 'redshawk@example.com',
          telephone: '07722009944',
        }
      end

      before do
        contact
        create_key_contacts_csv_file(filename, [attrs])
        @service = described_class.new(KeyContactDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'assigns the contact as the key contact for the responsible body' do
        @service.import_contacts
        expect(responsible_body.reload.key_contact_id).to eq(User.last.id)
      end

      it 'flags the responsible body as in the devices pilot' do
        @service.import_contacts
        expect(responsible_body.reload.in_devices_pilot?).to be true
      end

      it 'queues an email to the contact' do
        expect {
          @service.import_contacts
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).once
      end
    end
  end
end
