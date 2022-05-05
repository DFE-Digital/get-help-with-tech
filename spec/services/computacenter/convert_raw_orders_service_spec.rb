require 'rails_helper'

RSpec.describe Computacenter::ConvertRawOrdersService do
  describe '#call' do
    let(:raw_order) { create(:computacenter_raw_order) }
    let(:scope) { Computacenter::RawOrder.where(id: raw_order.id) }
    let(:service) { described_class.new(scope:) }

    context 'with a RawOrder' do
      it 'creates an Order' do
        expect { service.call }.to change(Computacenter::Order, :count)
      end

      it 'creates the corresponding Order' do
        service.call
        expect(raw_order.order).to have_attributes(
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

      it 'does not create a new Order if the RawOrder is already mapped' do
        service.call
        expect { service.call }.not_to change(Computacenter::Order, :count)
      end
    end
  end
end
