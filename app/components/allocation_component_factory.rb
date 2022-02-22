class AllocationComponentFactory
  def self.create_component(organisation)
    AllocationComponent.new(
      organisation:,
      devices_available: organisation.devices_available_to_order(:laptop),
      devices_ordered: organisation.devices_ordered(:laptop),
      routers_ordered: organisation.devices_ordered(:router),
      devices_allocation: organisation.allocation(:laptop),
    )
  end
end
