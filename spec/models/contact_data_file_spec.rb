require 'rails_helper'

RSpec.describe ContactDataFile, type: :model do
  describe '#contacts' do
    let(:filename) { Rails.root.join('tmp/contact_test_data.csv') }

    context 'when a school is open and not an excluded type' do
      let(:attrs) do
        {
          urn: '103001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Voluntary aided school',
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
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the contact data' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          urn: '103001',
          email_address: 'Joanne.Smith@myschool.gov.uk',
          full_name: 'Joanne Smith',
          title: 'Head Teacher',
          phone_number: '0123456789',
        )
      end
    end

    context 'when an alternate title is specified for the headteacher' do
      let(:attrs) do
        {
          urn: '103001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Voluntary aided school',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Joanne',
          head_last_name: 'Smith',
          head_email: 'Joanne.Smith@myschool.gov.uk',
          head_title: 'Head Teacher',
          head_preferred_title: 'Principal',
          telephone: '0123456789',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the preferred title' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          urn: '103001',
          email_address: 'Joanne.Smith@myschool.gov.uk',
          full_name: 'Joanne Smith',
          title: 'Principal',
          phone_number: '0123456789',
        )
      end
    end

    context 'when the head email is not present' do
      let(:attrs) do
        {
          urn: '103001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Voluntary aided school',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Gary',
          head_last_name: 'Jenkins',
          main_email: 'admin@myschool.gov.uk',
          head_title: 'Head',
          telephone: '0123456789',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'uses the main email' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          urn: '103001',
          email_address: 'admin@myschool.gov.uk',
          full_name: 'Gary Jenkins',
          title: 'Head',
          phone_number: '0123456789',
        )
      end
    end

    context 'when the head and main emails are not present' do
      let(:attrs) do
        {
          urn: '103001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Voluntary aided school',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Floss',
          head_last_name: 'Williams',
          alt_email: 'c.kelly@bigschool.com',
          head_title: 'Head Teacher (acting)',
          telephone: '0123456789',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'uses the alternate email' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          urn: '103001',
          email_address: 'c.kelly@bigschool.com',
          full_name: 'Floss Williams',
          title: 'Head Teacher (acting)',
          phone_number: '0123456789',
        )
      end
    end

    context 'when none of the emails are populated' do
      let(:attrs) do
        {
          urn: '103001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Voluntary aided school',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Darren',
          head_last_name: 'Carmichael',
          head_title: 'Head Teacher',
          telephone: '0123456789',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'does not populate the email address' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          urn: '103001',
          email_address: nil,
          full_name: 'Darren Carmichael',
          title: 'Head Teacher',
          phone_number: '0123456789',
        )
      end
    end

    context 'when none of the title options are populated' do
      let(:attrs) do
        {
          urn: '103001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Voluntary aided school',
          group_type: 'Local authority maintained schools',
          head_email: 'head@camden-school.org',
          head_first_name: 'Christine',
          head_last_name: 'Davis',
          telephone: '0123456789',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'defaults to Headteacher as the title' do
        contacts = described_class.new(filename).contacts
        expect(contacts.first).to include(
          urn: '103001',
          email_address: 'head@camden-school.org',
          full_name: 'Christine Davis',
          title: 'Headteacher',
          phone_number: '0123456789',
        )
      end
    end

    context 'when a school is closed' do
      let(:attrs) do
        {
          urn: '100001',
          responsible_body: 'Camden',
          status: 'Closed',
          group_type: 'Local authority maintained schools',
          head_first_name: 'Arthur',
          head_last_name: 'Askey',
          head_email: 'a.askey@myschool.gov.uk',
          head_title: 'Headmaster',
          telephone: '02930222001',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'does not retrieve the contact data' do
        contacts = described_class.new(filename).contacts
        expect(contacts).to be_empty
      end
    end

    context 'when a school is open but an excluded type' do
      let(:attrs) do
        {
          urn: '100001',
          responsible_body: 'Camden',
          status: 'Open',
          type: 'Other independent school',
          group_type: 'Independent schools',
          head_first_name: 'Jacqueline',
          head_last_name: 'Harris',
          head_email: 'j.harris@myschool.gov.uk',
          head_title: 'Acting Head',
          telephone: '05933-011-251 Ext 23',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'does not retrieve the school data' do
        contacts = described_class.new(filename).contacts
        expect(contacts).to be_empty
      end
    end
  end
end
