require 'rails_helper'

RSpec.describe Computacenter::ExportOrdersToFileService do
  describe '#call' do
    let(:csv) { CSV.read(filename, headers: true) }
    let(:expected_headers) { Computacenter::OrderReport.headers }
    let(:filename) { Rails.root.join('tmp/computacenter_export_orders_test_data.csv') }
    let(:orders) { create_list(:computacenter_order, 2) }
    let(:order_ids) { orders.map(&:id) }
    let(:order_csv_row) { csv.first }
    let(:service) { described_class.new(filename, order_ids:) }

    after do
      remove_file(filename)
    end

    context 'when given a filename' do
      before do
        service.call
      end

      it 'creates a CSV file' do
        expect(File.exist?(filename)).to be true
      end

      it 'includes a heading row and all orders in the CSV file' do
        line_count = `wc -l "#{filename}"`.split.first.to_i
        expect(line_count).to eq(orders.count + 1)
      end

      it 'includes the correct headers' do
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context 'when orders are in scope' do
      let(:order) { orders.first }
      let(:orders) { create_list(:computacenter_order, 1) }

      before do
        service.call
      end

      it 'displays "customer_order_number" in the "order_number" column' do
        expect(order_csv_row['order_number']).to eq(order.customer_order_number)
      end

      it 'has a order_date value equal to the order order_date' do
        expect(order_csv_row['order_date']).to eq(order.order_date.to_s)
      end

      it 'has a quantity value equal to the order quantity_ordered' do
        expect(order_csv_row['quantity']).to eq(order.quantity_ordered.to_s)
      end

      it 'has a device_type value equal to the order persona' do
        expect(order_csv_row['device_type']).to eq(order.persona)
      end
    end
  end
end
