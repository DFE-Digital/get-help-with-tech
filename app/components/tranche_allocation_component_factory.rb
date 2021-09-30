class TrancheAllocationComponentFactory
  def self.create_component(organisation)
    TrancheAllocationComponent.new(
      organisation: organisation,
      devices_remaining: organisation.laptops_available_to_order,
      routers_remaining: organisation.routers_available_to_order,
      devices_ordered: organisation.laptops_ordered,
      routers_ordered: organisation.routers_ordered,
      devices_allocation: organisation.laptop_allocation,
      routers_allocation: organisation.router_allocation,
    )
  end
end
