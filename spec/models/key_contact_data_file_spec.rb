require 'rails_helper'

RSpec.describe KeyContactDataFile, type: :model do
  describe '#contacts' do
    let(:filename) { Rails.root.join('tmp/key_contact_test_data.csv') }
    let(:csv_data_map) do
      {
        id: 'ID',
        email_address: 'Email',
        full_name: 'Name',
        telephone: 'Telephone',
      }
    end

    context 'when all contact data is present' do
      let(:attrs) do
        {
          id: '103',
          email_address: 'cc@example.com',
          full_name: 'Chuck Coles',
          telephone: '0123456789',
        }
      end

      before do
        create_csv_file(filename, csv_data_map.values, [attrs], csv_data_map)
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the contact data' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          id: '103',
          email_address: 'cc@example.com',
          full_name: 'Chuck Coles',
          telephone: '0123456789',
        )
      end
    end

    context 'when name is missing' do
      let(:attrs) do
        {
          id: '3001',
          email_address: 'Wilma.Benzine@example.com',
          telephone: '0123456789',
        }
      end

      before do
        create_csv_file(filename, csv_data_map.values, [attrs], csv_data_map)
      end

      after do
        remove_file(filename)
      end

      it 'populates full_name with the email address' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          id: '3001',
          email_address: 'wilma.benzine@example.com',
          full_name: 'wilma.benzine@example.com',
          telephone: '0123456789',
        )
      end
    end

    context 'when the email is not lower case' do
      let(:attrs) do
        {
          id: '111',
          email_address: 'Gary.Spink@EXAMPLE.COM',
          full_name: 'Gary Spink',
          telephone: '0123456789',
        }
      end

      before do
        create_csv_file(filename, csv_data_map.values, [attrs], csv_data_map)
      end

      after do
        remove_file(filename)
      end

      it 'converts the email address to lower-case' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          id: '111',
          email_address: 'gary.spink@example.com',
          full_name: 'Gary Spink',
          telephone: '0123456789',
        )
      end
    end
  end
end
