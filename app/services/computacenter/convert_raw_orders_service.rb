# Service to convert imported raw order data
class Computacenter::ConvertRawOrdersService < ApplicationService
  def initialize(scope: Computacenter::RawOrder.unprocessed)
    @scope = scope
    validate_scope!
  end

  def call
    scope.find_each do |raw_order|
      persist!(raw_order)
    end
  end

private

  attr_reader :scope

  def invalid_scope!
    raise('scope must be a Computacenter::RawOrder::ActiveRecord_Relation')
  end

  def persist!(raw_order)
    Computacenter::RawOrderMap.new(raw_order:).persist!
  end

  def scope?
    scope.is_a?(Computacenter::RawOrder.const_get(:ActiveRecord_Relation))
  end

  def validate_scope!
    invalid_scope! unless scope?
  end
end
