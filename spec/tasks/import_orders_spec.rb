require 'rails_helper'

Rails.application.load_tasks

describe 'import_orders' do
  describe '#convert' do
    let(:convert) { Rake::Task['import_orders:convert'] }

    before do
      create(:computacenter_raw_order)
    end

    it 'converts unprocessed RawOrders to Orders' do
      expect { convert.invoke }.to change(Computacenter::Order, :count).by(1)
    end
  end

  describe '#ingest' do
    let(:ingest) { Rake::Task['import_orders:ingest'] }
    let(:path) { Rails.root.join('spec/fixtures/files/orders.csv') }

    before do
      ENV['ORDERS_FILE_PATH'] = path.to_s
    end

    it 'imports the raw orders' do
      expect { ingest.invoke }.to change(Computacenter::RawOrder, :count).by(2)
    end
  end
end
