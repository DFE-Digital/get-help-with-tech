require 'rails_helper'

RSpec.describe CsvDataFileImporter do
  context 'given a CsvDataFile object' do
    let(:mock_csv_data_file) { instance_double(Computacenter::SoldToDataFile) }
    subject(:importer) { CsvDataFileImporter.new(csv_data_file: mock_csv_data_file) }

    describe '#import!' do
      let(:record_1) { {id: 'ID 1', a_field: 'a field 1'} }
      let(:record_2) { {id: 'ID 2', a_field: 'a field 2'} }

      before do
        allow(mock_csv_data_file).to receive(:records).and_yield(record_1).and_yield(record_2)
        allow(mock_csv_data_file).to receive(:import_record!)
      end

      it 'calls import_record! with each record in the given csv_data_file' do
        importer.import!
        expect(mock_csv_data_file).to have_received(:import_record!).with(record_1).ordered
        expect(mock_csv_data_file).to have_received(:import_record!).with(record_2).ordered
      end

      context 'when importing a record raises an error' do
        before do
          allow(mock_csv_data_file).to receive(:import_record!).with(record_1)
          allow(mock_csv_data_file).to receive(:import_record!).with(record_2).and_raise(ActiveRecord::RecordNotFound, 'could not find some things')
        end

        it 'does not let the error bubble out' do
          expect { importer.import! }.not_to raise_error
        end

        it 'stores the error and record as a failure' do
          importer.import!
          expect(importer.failures.size).to eq(1)
          expect(importer.failures[0][:record]).to eq(record_2)
          expect(importer.failures[0][:error].message).to eq('could not find some things')
        end
      end
    end
  end
end
