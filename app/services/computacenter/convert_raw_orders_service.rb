# Service to convert imported raw order data
class Computacenter::ConvertRawOrdersService < ApplicationService
  def initialize(scope: Computacenter::RawOrder.unprocessed)
    if scope.nil? || !scope.is_a?(Computacenter::RawOrder.const_get(:ActiveRecord_Relation))
      raise('scope must be a Computacenter::RawOrder::ActiveRecord_Relation')
    end

    @scope = scope
  end

  def call
    scope.map do |raw_order|
      order = Computacenter::Order.first_or_create!(raw_order_id: raw_order.id)
      attributes = Computacenter::RawOrderMap.new(raw_order:).to_order_attributes.except(:raw_order)

      if order.valid?
        order.transaction do
          order.update!(**attributes)
          raw_order.mark_as_processed!
        end
      end

      order
    end
  end

private

  attr_reader :scope
end
