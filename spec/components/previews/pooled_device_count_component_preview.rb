class PooledDeviceCountComponentPreview < ViewComponent::Preview
  def ordered_devices_and_none_left
    rb = FactoryBot.build(:trust, laptops: [10, 10, 10])

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    render(component)
  end

  def ordered_all_and_none_left
    rb = FactoryBot.build(:trust, laptops: [10, 10, 10], routers: [10, 10, 10])

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    render(component)
  end

  def ordered_routers_and_none_left
    rb = FactoryBot.build(:trust, routers: [10, 10, 10])

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    render(component)
  end

  def not_ordered_and_devices_plus_routers_left
    rb = FactoryBot.build(:trust, laptops: [2, 2, 0], routers: [3, 3, 0])

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    render(component)
  end

  def ordered_and_devices_plus_routers_left
    rb = FactoryBot.build(:trust, laptops: [3, 3, 1], routers: [4, 4, 2])

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    render(component)
  end
end
