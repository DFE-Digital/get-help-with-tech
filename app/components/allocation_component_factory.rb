class AllocationComponentFactory
  def self.create_component(organisation)
    AllocationComponent.new(
      organisation: organisation,
      devices_ordered: organisation.devices_ordered(:laptop),
      routers_ordered: organisation.devices_ordered(:router),
      devices_allocation: organisation.allocation(:laptop),
    )
  end
end
