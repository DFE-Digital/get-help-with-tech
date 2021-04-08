class PooledDeviceCountComponentPreview < ViewComponent::Preview
  def ordered_devices_and_none_left
    rb = FactoryBot.build(:trust)
    rb.virtual_cap_pools = [VirtualCapPool.new(device_type: 'std_device', devices_ordered: 10)]

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    component.instance_eval do
      def allocations
        responsible_body.virtual_cap_pools
      end
    end

    render(component)
  end

  def ordered_all_and_none_left
    rb = FactoryBot.build(:trust)
    rb.virtual_cap_pools = [VirtualCapPool.new(device_type: 'std_device', devices_ordered: 10),
                            VirtualCapPool.new(device_type: 'coms_device', devices_ordered: 10)]

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    component.instance_eval do
      def allocations
        responsible_body.virtual_cap_pools
      end
    end

    render(component)
  end

  def ordered_routers_and_none_left
    rb = FactoryBot.build(:trust)
    rb.virtual_cap_pools = [VirtualCapPool.new(device_type: 'coms_device', devices_ordered: 10)]

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    component.instance_eval do
      def allocations
        responsible_body.virtual_cap_pools
      end
    end

    render(component)
  end

  def not_ordered_and_devices_plus_routers_left
    rb = FactoryBot.build(:trust)
    rb.virtual_cap_pools = [VirtualCapPool.new(device_type: 'std_device', cap: 2, devices_ordered: 0),
                            VirtualCapPool.new(device_type: 'coms_device', cap: 3, devices_ordered: 0)]

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    component.instance_eval do
      def allocations
        responsible_body.virtual_cap_pools
      end
    end

    render(component)
  end

  def ordered_and_devices_plus_routers_left
    rb = FactoryBot.build(:trust)
    rb.virtual_cap_pools = [VirtualCapPool.new(device_type: 'std_device', cap: 3, devices_ordered: 1),
                            VirtualCapPool.new(device_type: 'coms_device', cap: 4, devices_ordered: 2)]

    component = ResponsibleBody::PooledDeviceCountComponent.new(responsible_body: rb)

    component.instance_eval do
      def allocations
        responsible_body.virtual_cap_pools
      end
    end

    render(component)
  end
end
