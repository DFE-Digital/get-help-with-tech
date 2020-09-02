require 'rails_helper'

RSpec.describe Computacenter::SoldToDataFile do
  subject(:data_file) { described_class.new('/dev/null') }

  let(:row) do
    {
      'URN' => 'LEA000',
      'Name 1' => 'the name',
      'Customer' => 'customer id',
    }
  end
  let(:expected_record) do
    {
      urn: 'LEA000',
      name: 'the name',
      sold_to: 'customer id',
    }
  end

  describe '#extract_record' do
    it 'returns a hash with the expected fields' do
      expect(data_file.extract_record(row)).to eq(expected_record)
    end
  end

  describe '#import_record!' do
    let(:local_authority) { create(:local_authority, gias_id: '000', computacenter_reference: nil) }

    it 'updates the ResponsibleBody that matches the urn, setting computacenter_reference to :sold_to' do
      expect { data_file.import_record!(expected_record) }.to change { local_authority.reload.computacenter_reference }.from(nil).to('customer id')
    end
  end
end
