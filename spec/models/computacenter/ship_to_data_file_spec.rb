require 'rails_helper'

RSpec.describe Computacenter::ShipToDataFile do
  subject(:data_file) { described_class.new('/dev/null') }

  let(:row) do
    {
      'URN' => '999900',
      'Name 1' => 'the name',
      'Ship to acct' => 'account id',
    }
  end
  let(:expected_record) do
    {
      urn: '999900',
      name: 'the name',
      ship_to: 'account id',
    }
  end

  describe '#extract_record' do
    it 'returns a hash with the expected fields' do
      expect(data_file.extract_record(row)).to eq(expected_record)
    end
  end

  describe '#import_record!' do
    let(:school) { create(:school, urn: '999900', computacenter_reference: nil) }

    it 'updates the school that matches the urn, setting computacenter_reference to :sold_to' do
      expect { data_file.import_record!(expected_record) }.to change { school.reload.computacenter_reference }.from(nil).to('account id')
    end
  end
end
