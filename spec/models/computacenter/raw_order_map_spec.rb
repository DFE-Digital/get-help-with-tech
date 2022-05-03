require 'rails_helper'

RSpec.describe Computacenter::RawOrderMap, type: :model do
  let(:raw_order) { build_stubbed(:computacenter_raw_order) }
  let(:raw_order_map) { build(:computacenter_raw_order_map, raw_order:) }

  describe '#to_order' do
    it 'returns an Order' do
      expect(raw_order_map.to_order).to be_a(Computacenter::Order)
    end

    it 'returns an Order with the correct attributes' do
      expect(raw_order_map.to_order).to have_attributes(
        source: raw_order.source,
        sold_to: raw_order.sold_to_account_no.to_i,
        ship_to: raw_order.ship_to_account_no.to_i,
        sales_order_number: raw_order.sales_order_number.to_i,
        persona: raw_order.persona_cleaned,
        material_number: raw_order.material_number.to_i,
        material_description: raw_order.material_description,
        manufacturer: raw_order.manufacturer_cleaned,
        quantity_ordered: raw_order.quantity_ordered.to_i,
        quantity_outstanding: raw_order.quantity_outstanding.to_i,
        quantity_completed: raw_order.quantity_completed.to_i,
        order_date: raw_order.converted_order_date,
        despatch_date: raw_order.converted_despatch_date,
        order_completed: raw_order.order_completed.upcase == 'TRUE',
        is_return: raw_order.is_return.upcase == 'TRUE',
        customer_order_number: raw_order.customer_order_number,
        raw_order:,
      )
    end
  end

  describe '#to_order_attributes' do
    it 'returns an attributes Hash' do
      expect(raw_order_map.to_order_attributes).to be_a(Hash)
    end

    it 'returns an Order with the correct attributes' do
      expect(raw_order_map.to_order_attributes).to include(
        source: raw_order.source,
        sold_to: raw_order.sold_to_account_no.to_i,
        ship_to: raw_order.ship_to_account_no.to_i,
        sales_order_number: raw_order.sales_order_number.to_i,
        persona: raw_order.persona_cleaned,
        material_number: raw_order.material_number.to_i,
        material_description: raw_order.material_description,
        manufacturer: raw_order.manufacturer_cleaned,
        quantity_ordered: raw_order.quantity_ordered.to_i,
        quantity_outstanding: raw_order.quantity_outstanding.to_i,
        quantity_completed: raw_order.quantity_completed.to_i,
        order_date: raw_order.converted_order_date,
        despatch_date: raw_order.converted_despatch_date,
        order_completed: raw_order.order_completed.upcase == 'TRUE',
        is_return: raw_order.is_return.upcase == 'TRUE',
        customer_order_number: raw_order.customer_order_number,
        raw_order:,
      )
    end
  end
end
