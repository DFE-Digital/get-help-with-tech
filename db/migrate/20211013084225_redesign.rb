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

    drop_table :preorder_information
    drop_table :school_virtual_caps
    drop_table :school_device_allocations
    drop_table :virtual_cap_pools
  end

  def down
    create_preorder_information_table
    create_school_virtual_caps_table
    create_school_device_allocations_table

    create_virtual_cap_pools_table
    copy_allocation_data_into_virtual_cap_pools
    copy_school_data_into_entities

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

    # From virtual_cap_pools
    remove_column :responsible_bodies, :laptop_allocation
    remove_column :responsible_bodies, :laptop_cap
    remove_column :responsible_bodies, :laptops_ordered
    remove_column :responsible_bodies, :router_allocation
    remove_column :responsible_bodies, :router_cap
    remove_column :responsible_bodies, :routers_ordered
  end
end

def associate_allocation_changes_to_schools
  AllocationChange.find_each do |allocation_change|
    sda = SchoolDeviceAllocation.find(allocation_change.school_device_allocation_id)
    allocation_change.update!(school_id: sda.school_id,
                              device_type: DEVICE_TYPES[sda.school.device_type])
  end
  remove_column :allocation_changes, :school_device_allocation_id
end

def associate_cap_update_calls_to_schools
  CapUpdateCall.find_each do |cap_update_call|
    sda = SchoolDeviceAllocation.find(cap_update_call.school_device_allocation_id)
    cap_update_call.update!(school_id: sda.school_id,
                            device_type: DEVICE_TYPES[sda.school.device_type])
  end
  remove_column :cap_update_calls, :school_device_allocation_id
end

def copy_allocation_data_into_rbs
  VirtualCapPool.find_each do |vcp|
    if vcp.device_type == 'std_device'
      copy_laptop_allocation_data_into_rb(rb, vcp.responsible_body)
    else
      copy_router_allocation_data_into_rb(rb, vcp.responsible_body)
    end
  end
end

def copy_allocation_data_into_schools
  SchoolDeviceAllocation.includes(:school_virtual_cap, school: %i[responsible_body users]).find_each do |sda|
    # puts "SchoolDeviceAllocation: #{sda.id}"
    if sda.device_type == 'std_device'
      copy_laptop_allocation_data_into_school(sda.school, sda)
    else
      copy_router_allocation_data_into_school(sda.school, sda)
    end
  end
end

def copy_allocation_data_into_virtual_cap_pools
  ResponsibleBody.find_each { |rb| create_virtual_cap_pools_for(rb) }
end

def copy_laptop_allocation_data_into_rb(responsible_body, vcp)
  responsible_body.update!(laptop_allocation: vcp.allocation,
                           laptop_cap: vcp.cap,
                           laptops_ordered: vcp.devices_ordered)
end

def copy_laptop_allocation_data_into_school(school, sda)
  school.update!(raw_laptop_allocation: sda.raw_allocation,
                 raw_laptop_cap: sda.raw_cap,
                 raw_laptops_ordered: sda.raw_devices_ordered,
                 laptop_cap_update_request_timestamp: sda.cap_update_request_timestamp,
                 laptop_cap_update_request_payload_id: sda.cap_update_request_payload_id)
end

def copy_preorder_information_into_schools
  PreorderInformation.includes(school: %i[responsible_body users]).find_each do |preorder_informacion|
    # puts "PreorderInformacion: #{preorder_informacion.id}"
    school = preorder_informacion.school
    school.update!(who_will_order_devices: preorder_informacion.who_will_order_devices,
                   preorder_status: preorder_informacion.status,
                   school_contact_id: preorder_informacion.school_contact_id,
                   will_need_chromebooks: preorder_informacion.will_need_chromebooks,
                   school_or_rb_domain: preorder_informacion.school_or_rb_domain,
                   recovery_email_address: preorder_informacion.recovery_email_address,
                   school_contacted_at: preorder_informacion.school_contacted_at)
  end
end

def copy_router_allocation_data_into_rb(responsible_body, vcp)
  responsible_body.update!(router_allocation: vcp.allocation,
                           router_cap: vcp.cap,
                           routers_ordered: vcp.devices_ordered)
end

def copy_router_allocation_data_into_school(school, sda)
  school.update!(raw_router_allocation: sda.raw_allocation,
                 raw_router_cap: sda.raw_cap,
                 raw_routers_ordered: sda.raw_devices_ordered,
                 router_cap_update_request_timestamp: sda.cap_update_request_timestamp,
                 router_cap_update_request_payload_id: sda.cap_update_request_payload_id)
end

def copy_school_data_into_entities
  School.includes(:responsible_body).find_each do |school|
    # puts "School: #{school.id}"
    create_preorder_information_for(school)
    create_std_device_allocation_for(school)
    create_coms_device_allocation_for(school)
  end
end

def create_coms_device_allocation_for(school)
  if [school.raw_router_allocation, school.raw_router_cap, school.raw_routers_ordered].any?(&:positive?) || [school.router_cap_update_request_timestamp, school.router_cap_update_request_payload_id].any?(&:present?)
    router_sda = SchoolDeviceAllocation.create!(school_id: school.id,
                                                device_type: 'coms_device',
                                                allocation: school.raw_router_allocation,
                                                cap: school.raw_router_cap,
                                                devices_ordered: school.raw_routers_ordered,
                                                cap_update_request_timestamp: school.router_cap_update_request_timestamp,
                                                cap_update_request_payload_id: school.router_cap_update_request_payload_id)
    create_coms_device_school_virtual_cap_for(school, router_sda)
    move_coms_device_allocation_changes_to(school, router_sda)
    move_coms_device_cap_update_calls_to(school, router_sda)
  end
end

def create_coms_device_school_virtual_cap_for(school, coms_device_allocation)
  if school.in_virtual_cap_pool?
    SchoolVirtualCap.create!(school_device_allocation_id: coms_device_allocation.id,
                             virtual_cap_pool_id: VirtualCapPool.where(responsible_body_id: school.responsible_body_id, device_type: 'coms_device').pick(:id))
  end
end

def create_laptop_virtual_cap_pool_for(responsible_body)
  if [responsible_body.laptop_allocation, responsible_body.laptop_cap, responsible_body.laptops_ordered].any?(&:positive?)
    VirtualCapPool.create!(responsible_body_id: responsible_body.id,
                           device_type: 'std_device',
                           allocation: responsible_body.laptop_allocation,
                           cap: responsible_body.laptop_cap,
                           devices_ordered: responsible_body.laptops_ordered)
  end
end

def create_preorder_information_for(school)
  PreorderInformation.create!(school: school,
                              who_will_order_devices: school.who_will_order_devices,
                              status: school.preorder_status,
                              school_contact_id: school.school_contact_id,
                              will_need_chromebooks: school.will_need_chromebooks,
                              school_or_rb_domain: school.school_or_rb_domain,
                              recovery_email_address: school.recovery_email_address,
                              school_contacted_at: school.school_contacted_at)
end

def create_preorder_information_table
  create_table :preorder_information do |t|
    t.string :who_will_order_devices, null: false
    t.string :status, null: false, index: true
    t.bigint :school_contact_id, index: true
    t.string :will_need_chromebooks
    t.string :school_or_rb_domain
    t.string :recovery_email_address
    t.datetime :school_contacted_at

    t.references :school, null: false

    t.timestamps
  end
end

def create_router_virtual_cap_pool_for(responsible_body)
  if [responsible_body.router_allocation, responsible_body.router_cap, responsible_body.routers_ordered].any?(&:positive?)
    VirtualCapPool.create!(responsible_body_id: responsible_body.id,
                           device_type: 'coms_device',
                           allocation: responsible_body.router_allocation,
                           cap: responsible_body.router_cap,
                           devices_ordered: responsible_body.routers_ordered)
  end
end

def create_school_device_allocations_table
  create_table :school_device_allocations do |t|
    t.string :device_type, null: false
    t.integer :allocation, default: 0, null: false
    t.integer :devices_ordered, default: 0, null: false
    t.bigint :last_updated_by_user_id, index: true
    t.bigint :created_by_user_id, index: true
    t.integer :cap, default: 0, null: false, index: true
    t.datetime :cap_update_request_timestamp, index: { name: 'ix_allocations_cap_update_timestamp' }
    t.string :cap_update_request_payload_id, index: { name: 'ix_allocations_cap_update_payload_id' }

    t.references :school, null: false

    t.timestamps
  end
end

def create_school_virtual_caps_table
  create_table :school_virtual_caps do |t|
    t.references :virtual_cap_pool, null: false
    t.references :school_device_allocation, null: false

    t.timestamps
  end
end

def create_std_device_allocation_for(school)
  if [school.raw_laptop_allocation, school.raw_laptop_cap, school.raw_laptops_ordered].any?(&:positive?) || [school.laptop_cap_update_request_timestamp, school.laptop_cap_update_request_payload_id].any?(&:present?)
    laptop_sda = SchoolDeviceAllocation.create!(school_id: school.id,
                                                device_type: 'std_device',
                                                allocation: school.raw_laptop_allocation,
                                                cap: school.raw_laptop_cap,
                                                devices_ordered: school.raw_laptops_ordered,
                                                cap_update_request_timestamp: school.laptop_cap_update_request_timestamp,
                                                cap_update_request_payload_id: school.laptop_cap_update_request_payload_id)
    create_std_device_school_virtual_cap_for(school, laptop_sda)
    move_std_device_allocation_changes_to(school, laptop_sda)
    move_std_device_cap_update_calls_to(school, laptop_sda)
  end
end

def create_std_device_school_virtual_cap_for(school, std_device_allocation)
  if school.in_virtual_cap_pool?
    SchoolVirtualCap.create!(school_device_allocation_id: std_device_allocation.id,
                             virtual_cap_pool_id: VirtualCapPool.where(responsible_body_id: school.responsible_body_id, device_type: 'std_device').pick(:id))
  end
end

def create_virtual_cap_pools_for(responsible_body)
  create_laptop_virtual_cap_pool_for(responsible_body)
  create_router_virtual_cap_pool_for(responsible_body)
end

def create_virtual_cap_pools_table
  create_table :virtual_cap_pools do |t|
    t.string :device_type, null: false
    t.integer :allocation, default: 0, null: false
    t.integer :cap, default: 0, null: false
    t.integer :devices_ordered, default: 0, null: false

    t.references :responsible_body, null: false

    t.timestamps

    t.index %i[device_type responsible_body_id]
  end
end

def move_coms_device_allocation_changes_to(school, router_sda)
  unless column_exists?(:allocation_changes, :school_device_allocation_id)
    add_column :allocation_changes, :school_device_allocation_id, :bigint, null: false, index: true, default: router_sda.id
  end

  school.allocation_changes.where(device_type: :router).each do |allocation_change|
    allocation_change.update!(school_device_allocation_id: router_sda.id)
  end
end

def move_coms_device_cap_update_calls_to(school, router_sda)
  unless column_exists?(:cap_update_calls, :school_device_allocation_id)
    add_column :cap_update_calls, :school_device_allocation_id, :bigint, null: false, index: true, default: router_sda.id
  end

  school.cap_update_calls.where(device_type: :router).each do |cap_update_call|
    cap_update_call.update!(school_device_allocation_id: router_sda.id)
  end
end

def move_std_device_allocation_changes_to(school, laptop_sda)
  unless column_exists?(:allocation_changes, :school_device_allocation_id)
    add_column :allocation_changes, :school_device_allocation_id, :bigint, null: false, index: true, default: laptop_sda.id
  end

  school.allocation_changes.where(device_type: :laptop).each do |allocation_change|
    allocation_change.update!(school_device_allocation_id: laptop_sda.id)
  end
end

def move_std_device_cap_update_calls_to(school, laptop_sda)
  unless column_exists?(:cap_update_calls, :school_device_allocation_id)
    add_column :cap_update_calls, :school_device_allocation_id, :bigint, null: false, index: true, default: laptop_sda.id
  end

  school.cap_update_calls.where(device_type: :laptop).each do |cap_update_call|
    cap_update_call.update!(school_device_allocation_id: laptop_sda.id)
  end
end
