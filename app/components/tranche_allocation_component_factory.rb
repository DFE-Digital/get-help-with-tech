class TrancheAllocationComponentFactory
  def self.create_component(organisation)
    TrancheAllocationComponent.new(
      organisation: organisation,
      devices_remaining: organisation.devices_available_to_order(:laptop),
      routers_remaining: organisation.devices_available_to_order(:router),
      devices_ordered: organisation.devices_ordered(:laptop),
      routers_ordered: organisation.devices_ordered(:router),
      devices_allocation: organisation.allocation(:laptop),
      routers_allocation: organisation.allocation(:router),
    )
  end
end
