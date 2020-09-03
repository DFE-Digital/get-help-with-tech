require 'rails_helper'

RSpec.describe Computacenter::ResponsibleBodyUsersDataFile do
  subject(:data_file) { described_class.new('/dev/null') }

  describe '#extract_record' do
    let(:row) do
      {
        'Title' => 'Mr. ',
        'First Name' => '  Aubrey M.',
        'Last Name' => 'Bracey  ',
        'Telephone' => '  01234 567 890 ',
        'Email' => '  aubrey@bracey.org',
        'DefaultSoldto' => '   987654 ',
        'SoldTos' => ' 111111,222222, 333333  , 444444'
      }
    end
    let(:record) { data_file.extract_record(row) }

    it 'joins Title, First Name and Last Name into :full_name, with leading/trailing spaces stripped' do
      expect(record[:full_name]).to eq('Mr. Aubrey M. Bracey')
    end

    it 'has :telephone equal to the Telephone element' do
      expect(record[:telephone]).to eq('01234 567 890')
    end

    it 'has :email_address equal to the Email element' do
      expect(record[:email_address]).to eq('aubrey@bracey.org')
    end

    it 'has :default_sold_to equal to the DefaultSoldto element' do
      expect(record[:default_sold_to]).to eq('987654')
    end

    it 'parses the given SoldTos into a stripped array' do
      expect(record[:sold_tos]).to eq(%w[111111 222222 333333 444444])
    end
  end

  describe 'find_responsible_body!' do
    let(:record) do
      {
        default_sold_to: '987654',
        sold_tos: %w[111111 222222 333333],
      }
    end

    context 'when a ResponsibleBody exists with the given DefaultSoldto' do
      let!(:existing_rb) { create(:local_authority, computacenter_reference: '987654') }

      it 'returns that ResponsibleBody' do
        expect(data_file.find_responsible_body!(record)).to eq(existing_rb)
      end
    end

    context 'when a ResponsibleBody only exists with one of the given SoldTos' do
      let!(:existing_rb) { create(:local_authority, computacenter_reference: '222222') }

      it 'returns that ResponsibleBody' do
        expect(data_file.find_responsible_body!(record)).to eq(existing_rb)
      end
    end

    context 'when no ResponsibleBody exists with any of the given sold to ids' do
      it 'returns nil' do
        expect(data_file.find_responsible_body!(record)).to be_nil
      end
    end
  end

  describe '#create_user!' do
    let(:record) do
      {
        full_name: 'A.A.R. deVark',
        email_address: 'aar@devark.com',
        telephone: '01234 567890',
      }
    end
    let(:responsible_body) { create(:trust) }

    it 'creates a user with the given attributes' do
      expect { data_file.create_user!(record, responsible_body) }.to change {User.count }.by(1)
      expect(User.last).to have_attributes(
        full_name: 'A.A.R. deVark',
        email_address: 'aar@devark.com',
        telephone: '01234 567890',
        responsible_body_id: responsible_body.id
      )
    end
  end

  describe 'import_record!' do
    context 'given a record with a corresponding ResponsibleBody' do
      let(:responsible_body) { create(:local_authority, computacenter_reference: '12345678') }
      let(:record) do
        {
          full_name: 'A.A.R. deVark',
          email_address: 'aar@devark.com',
          telephone: '01234 567890',
          default_sold_to: responsible_body.computacenter_reference,
          sold_tos: [responsible_body.computacenter_reference]
        }
      end

      it 'creates a user for the responsible body with the right attributes' do
        expect { data_file.import_record!(record) }.to change {User.count }.by(1)
        expect(User.last).to have_attributes(
          full_name: 'A.A.R. deVark',
          email_address: 'aar@devark.com',
          telephone: '01234 567890',
          responsible_body_id: responsible_body.id
        )
      end
    end

    context 'given a record with no corresponding ResponsibleBody' do
      let(:record) do
        {
          full_name: 'A.A.R. deVark',
          email_address: 'aar@devark.com',
          telephone: '01234 567890',
          default_sold_to: '00000000',
          sold_tos: %w[00000000]
        }
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect { data_file.import_record!(record) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
