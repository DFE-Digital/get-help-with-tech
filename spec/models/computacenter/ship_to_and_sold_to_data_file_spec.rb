require 'rails_helper'

RSpec.describe Computacenter::ShipToAndSoldToDataFile do
  subject(:data_file) { described_class.new('/dev/null') }

  describe '#extract_record' do
    let(:row) do
      {
        'Responsible Body URN' => '123',
        'Sold To Number' => '12345678',
        'School URN + School Name' => '56789 Some Comprehensive',
        'Ship To Number' => '987654',
      }
    end

    it 'extracts the Responsible Body URN to :rb_urn' do
      expect(data_file.extract_record(row)[:rb_urn]).to eq('123')
    end

    it 'extracts the Sold To Number to :rb_sold_to' do
      expect(data_file.extract_record(row)[:rb_sold_to]).to eq('12345678')
    end

    it 'extracts the school_urn from School URN + School Name' do
      expect(data_file.extract_record(row)[:school_urn]).to eq('56789')
    end

    it 'extracts the Ship To Number to :school_ship_to' do
      expect(data_file.extract_record(row)[:school_ship_to]).to eq('987654')
    end
  end

  describe '#import_record!' do
    let(:record) do
      {
        rb_urn: 't12345678',
        rb_sold_to: '987654',
        school_urn: '123456',
        school_ship_to: '654321',
      }
    end

    context 'when no ResponsibleBody exists with the given Computacenter URN' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { data_file.import_record!(record) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a matching ResponsibleBody and a school with the given URN exist' do
      before { create(:trust, companies_house_number: '12345678', computacenter_reference: nil) }

      let!(:school) { create(:school, urn: '123456', computacenter_reference: nil) }

      it 'updates the school computacenter_reference with the given :school_ship_to' do
        expect { data_file.import_record!(record) }.to change { school.reload.computacenter_reference }.from(nil).to('654321')
      end
    end

    context 'when a ResponsibleBody exists with the given Computacenter URN but no matching school' do
      let!(:trust) { create(:trust, companies_house_number: '12345678', computacenter_reference: nil) }

      it 'raises ActiveRecord::RecordNotFound, but still updates the ResponsibleBody computacenter_reference' do
        expect { data_file.import_record!(record) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(trust.reload.computacenter_reference).to eq('987654')
      end
    end
  end
end
