require 'rails_helper'

RSpec.describe ImportContactsService, type: :model do
  describe 'importing contacts' do
    let(:filename) { Rails.root.join('tmp/school_contact_data.csv') }
    let!(:school) { create(:school, urn: 103_001) }

    context 'when a contact does not already exist' do
      let(:attrs) do
        {
          urn: '103001',
          name: 'Little School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Voluntary aided school',
          trusts_flag: '0',
          phase: 'Primary',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Joanne',
          head_last_name: 'Smith',
          head_email: 'Joanne.Smith@myschool.gov.uk',
          head_title: 'Head Teacher',
          telephone: '0123456789',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
        @service = described_class.new(ContactDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'creates a new contact record' do
        expect {
          @service.import_contacts
        }.to change { school.contacts.count }.by(1)
      end

      it 'sets the correct values on the contact record' do
        @service.import_contacts
        expect(school.contacts.last).to have_attributes(
          email_address: 'Joanne.Smith@myschool.gov.uk',
          full_name: 'Joanne Smith',
          role: 'headteacher',
          title: 'Head Teacher',
          phone_number: '0123456789',
        )
      end

      it 'updates the phone_number on the school' do
        @service.import_contacts
        expect(school.reload.phone_number).to eq('0123456789')
      end
    end

    context 'when a contact already exists' do
      let!(:contact) { create(:school_contact, school:, email_address: 'head@myschool.gov.uk') }

      let(:attrs) do
        {
          urn: '103001',
          name: 'Little School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Voluntary aided school',
          trusts_flag: '0',
          phase: 'Primary',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Barry',
          head_last_name: 'Island',
          head_email: 'head@myschool.gov.uk',
          head_title: 'Principal',
          telephone: '07722009944',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
        described_class.new(ContactDataFile.new(filename)).import_contacts
      end

      after do
        remove_file(filename)
      end

      it 'updates the existing contact record' do
        expect(contact.reload).to have_attributes(
          full_name: 'Barry Island',
          email_address: 'head@myschool.gov.uk',
          title: 'Principal',
          phone_number: '07722009944',
        )
      end

      it 'updates the phone_number on the school' do
        expect(school.reload.phone_number).to eq('07722009944')
      end
    end
  end
end
