require 'rails_helper'

RSpec.describe 'importing Local Authority GIAS IDs from CSV' do
  let(:row) do
    {
      'Local Authority ENG' => 'BBB',
      'Local Authority GIAS ID' => '0123',
    }
  end

  subject(:data_file) { LocalAuthorityGiasIdsDataFile.new('/dev/null') }

  describe '#extract_record' do
    it 'extracts the eng code' do
      expect(data_file.extract_record(row)[:eng]).to eq('BBB')
    end

    it 'extracts the GIAS ID' do
      expect(data_file.extract_record(row)[:gias_id]).to eq('0123')
    end
  end

  describe '#import_record!' do
    let(:record) do
      {
        eng: 'BBB',
        gias_id: '0123',
      }
    end

    context 'when a LocalAuthority exists with the given ENG code' do
      let!(:local_authority) { create(:local_authority, local_authority_eng: 'BBB', gias_id: nil) }

      it 'updates the GIAS ID with the value from the given record' do
        expect { data_file.import_record!(record) }.to change { local_authority.reload.gias_id }.from(nil).to('0123')
      end
    end

    context 'when no LocalAuthority exists with the given ENG code' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { data_file.import_record!(record) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
