require 'rails_helper'

RSpec.describe Computacenter::RawOrder, type: :model do
  let(:raw_order) { build_stubbed(:computacenter_raw_order) }

  it 'returns a RawOrder' do
    expect(raw_order).to be_a(described_class)
  end

  describe 'processed' do
    it 'returns processed orders' do
      create(:computacenter_raw_order)
      create(:computacenter_raw_order, :processed)
      expect(described_class.processed.count).to eq(1)
    end
  end

  describe 'unprocessed' do
    it 'returns only unprocessed orders' do
      create(:computacenter_raw_order, :processed)
      unprocessed_order = create(:computacenter_raw_order)

      expect(described_class.unprocessed).to eq([unprocessed_order])
    end
  end

  describe 'updated' do
    it 'returns only updated orders' do
      create(:computacenter_raw_order)
      create(:computacenter_raw_order, :processed)
      updated_order = create(:computacenter_raw_order, :updated)

      expect(described_class.updated).to eq([updated_order])
    end
  end

  describe '#converted_order_date' do
    it 'returns a Date' do
      expect(raw_order.converted_order_date).to be_a(Date)
    end

    it 'returns the converted order date' do
      expect(raw_order.converted_order_date).to eq(Date.strptime(raw_order.order_date, '%m/%d/%Y'))
    end
  end

  describe '#converted_despatch_date' do
    it 'returns a Date' do
      expect(raw_order.converted_despatch_date).to be_a(Date)
    end

    it 'returns the converted despatch date' do
      expect(raw_order.converted_despatch_date).to eq(Date.strptime(raw_order.despatch_date, '%m/%d/%Y'))
    end
  end

  describe '#mark_as_processed!' do
    let(:raw_order) { create(:computacenter_raw_order) }

    it 'marks the order as processed' do
      raw_order.mark_as_processed!
      expect(raw_order.processed_at).to be_present
    end
  end
end
