class TrancheAllocationComponentFactory
  def self.create_component(organisation)
    TrancheAllocationComponent.new(
      organisation: organisation,
      devices_ordered: organisation.devices_ordered(:laptop),
      routers_ordered: organisation.devices_ordered(:router),
      devices_allocation: organisation.allocation(:laptop),
    )
  end
end
