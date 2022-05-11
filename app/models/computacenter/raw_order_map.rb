class Computacenter::RawOrderMap
  attr_reader :order, :raw_order

  def initialize(raw_order:)
    @raw_order = raw_order
    @order = Computacenter::Order.find_or_initialize_by(raw_order_id: raw_order.id)
  end

  delegate :valid?, to: :order

  def persist!
    return unless valid?

    order.transaction do
      order.update!(**order_attributes)
      raw_order.mark_as_processed!
    end
  end

private

  def order_attributes
    {
      source: raw_order.source,
      sold_to: raw_order.sold_to_account_no,
      ship_to: raw_order.ship_to_account_no,
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
      order_completed: raw_order.order_completed&.upcase == 'TRUE',
      is_return: raw_order.is_return&.upcase == 'TRUE',
      customer_order_number: raw_order.customer_order_number,
    }
  end
end
