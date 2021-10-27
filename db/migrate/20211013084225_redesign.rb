class Redesign < ActiveRecord::Migration[6.1]
  DEVICE_TYPES = {
    'std_device' => 'laptop',
    'coms_device' => 'router',
  }.freeze

  def up
    # From preorder_information
    add_column :schools, :preorder_status, :string, index: true
    add_column :schools, :school_contact_id, :bigint, index: true
    add_column :schools, :will_need_chromebooks, :string
    add_column :schools, :school_or_rb_domain, :string
    add_column :schools, :recovery_email_address, :string
    add_column :schools, :school_contacted_at, :datetime
    add_column :schools, :who_will_order_devices, :string, index: true

    # From std_device_allocation
    add_column :schools, :raw_laptop_allocation, :integer, default: 0, null: false
    add_column :schools, :raw_laptop_cap, :integer, default: 0, null: false
    add_column :schools, :raw_laptops_ordered, :integer, default: 0, null: false
    add_column :schools, :laptop_cap_update_request_timestamp, :datetime, index: true
    add_column :schools, :laptop_cap_update_request_payload_id, :string, index: true

    # From coms_device_allocation
    add_column :schools, :raw_router_allocation, :integer, default: 0, null: false
    add_column :schools, :raw_router_cap, :integer, default: 0, null: false
    add_column :schools, :raw_routers_ordered, :integer, default: 0, null: false
    add_column :schools, :router_cap_update_request_timestamp, :datetime, index: true
    add_column :schools, :router_cap_update_request_payload_id, :string, index: true

    # From cap_update_calls
    add_column :cap_update_calls, :school_id, :bigint, null: true, index: true
    add_column :cap_update_calls, :device_type, :string, null: false, default: 'laptop'

    # From allocation_changes
    add_column :allocation_changes, :school_id, :bigint, null: true, index: true
    add_column :allocation_changes, :device_type, :string, null: false, default: 'laptop'
    change_column_null :allocation_changes, :school_device_allocation_id, true

    # From virtual_cap_pools
    add_column :responsible_bodies, :laptop_allocation, :integer, default: 0, null: false
    add_column :responsible_bodies, :laptop_cap, :integer, default: 0, null: false
    add_column :responsible_bodies, :laptops_ordered, :integer, default: 0, null: false
    add_column :responsible_bodies, :router_allocation, :integer, default: 0, null: false
    add_column :responsible_bodies, :router_cap, :integer, default: 0, null: false
    add_column :responsible_bodies, :routers_ordered, :integer, default: 0, null: false

    School.update_all(preorder_status: 'needs_info', who_will_order_devices: 'responsible_body')

    copy_preorder_information_into_schools
    copy_allocation_data_into_schools
    associate_allocation_changes_to_schools
    associate_cap_update_calls_to_schools
    copy_allocation_data_into_rbs
  end

  def down
    # From preorder_information
    remove_column :schools, :preorder_status
    remove_column :schools, :school_contact_id
    remove_column :schools, :will_need_chromebooks
    remove_column :schools, :school_or_rb_domain
    remove_column :schools, :recovery_email_address
    remove_column :schools, :school_contacted_at
    remove_column :schools, :who_will_order_devices

    # From std_device_allocation
    remove_column :schools, :raw_laptop_allocation
    remove_column :schools, :raw_laptop_cap
    remove_column :schools, :raw_laptops_ordered
    remove_column :schools, :laptop_cap_update_request_timestamp
    remove_column :schools, :laptop_cap_update_request_payload_id

    # From coms_device_allocation
    remove_column :schools, :raw_router_allocation
    remove_column :schools, :raw_router_cap
    remove_column :schools, :raw_routers_ordered
    remove_column :schools, :router_cap_update_request_timestamp
    remove_column :schools, :router_cap_update_request_payload_id

    # From cap_update_calls
    remove_column :cap_update_calls, :school_id
    remove_column :cap_update_calls, :device_type

    # From allocation_changes
    remove_column :allocation_changes, :school_id
    remove_column :allocation_changes, :device_type
    change_column_null :allocation_changes, :school_device_allocation_id, false

    # From virtual_cap_pools
    remove_column :responsible_bodies, :laptop_allocation
    remove_column :responsible_bodies, :laptop_cap
    remove_column :responsible_bodies, :laptops_ordered
    remove_column :responsible_bodies, :router_allocation
    remove_column :responsible_bodies, :router_cap
    remove_column :responsible_bodies, :routers_ordered
  end

private

  def associate_allocation_changes_to_schools
    AllocationChange.find_each do |allocation_change|
      sda = SchoolDeviceAllocation.find(allocation_change.school_device_allocation_id)
      allocation_change.update_columns(school_id: sda.school_id,
                                       device_type: DEVICE_TYPES[sda.device_type])
    end
  end

  def associate_cap_update_calls_to_schools
    CapUpdateCall.find_each do |cap_update_call|
      sda = SchoolDeviceAllocation.find(cap_update_call.school_device_allocation_id)
      cap_update_call.update_columns(school_id: sda.school_id,
                                     device_type: DEVICE_TYPES[sda.device_type])
    end
  end

  def copy_allocation_data_into_rbs
    VirtualCapPool.find_each do |vcp|
      if vcp.device_type == 'std_device'
        copy_laptop_allocation_data_into_rb(vcp)
      else
        copy_router_allocation_data_into_rb(vcp)
      end
    end
  end

  def copy_allocation_data_into_schools
    SchoolDeviceAllocation.includes(:school_virtual_cap, school: %i[responsible_body users]).find_each do |sda|
      if sda.device_type == 'std_device'
        copy_laptop_allocation_data_into_school(sda.school, sda)
      else
        copy_router_allocation_data_into_school(sda.school, sda)
      end
    end
  end

  def copy_laptop_allocation_data_into_rb(vcp)
    vcp.responsible_body.update_columns(laptop_allocation: vcp.allocation,
                                        laptop_cap: vcp.cap,
                                        laptops_ordered: vcp.devices_ordered)
  end

  def copy_laptop_allocation_data_into_school(school, sda)
    school.update_columns(raw_laptop_allocation: sda.raw_allocation,
                          raw_laptop_cap: sda.raw_cap,
                          raw_laptops_ordered: sda.raw_devices_ordered,
                          laptop_cap_update_request_timestamp: sda.cap_update_request_timestamp,
                          laptop_cap_update_request_payload_id: sda.cap_update_request_payload_id)
  end

  def copy_preorder_information_into_schools
    PreorderInformation.includes(school: %i[responsible_body users]).find_each do |preorder_information|
      school = preorder_information.school
      school.update_columns(who_will_order_devices: preorder_information.who_will_order_devices,
                            preorder_status: preorder_information.status,
                            school_contact_id: preorder_information.school_contact_id,
                            will_need_chromebooks: preorder_information.will_need_chromebooks,
                            school_or_rb_domain: preorder_information.school_or_rb_domain,
                            recovery_email_address: preorder_information.recovery_email_address,
                            school_contacted_at: preorder_information.school_contacted_at)
    end
  end

  def copy_router_allocation_data_into_rb(vcp)
    vcp.responsible_body.update_columns(router_allocation: vcp.allocation,
                                        router_cap: vcp.cap,
                                        routers_ordered: vcp.devices_ordered)
  end

  def copy_router_allocation_data_into_school(school, sda)
    school.update_columns(raw_router_allocation: sda.raw_allocation,
                          raw_router_cap: sda.raw_cap,
                          raw_routers_ordered: sda.raw_devices_ordered,
                          router_cap_update_request_timestamp: sda.cap_update_request_timestamp,
                          router_cap_update_request_payload_id: sda.cap_update_request_payload_id)
  end
end
