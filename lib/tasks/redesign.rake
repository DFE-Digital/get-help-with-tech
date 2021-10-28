class Redesign
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

namespace :db do
  desc 'Migrate redesigned data'
  task migrate_redesign_data: :environment do
    redesign = Redesign.new
    redesign.copy_preorder_information_into_schools
    redesign.copy_allocation_data_into_schools
    redesign.associate_allocation_changes_to_schools
    redesign.associate_cap_update_calls_to_schools
    redesign.copy_allocation_data_into_rbs
  end
end
