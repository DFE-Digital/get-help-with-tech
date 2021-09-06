def create_schools_at_status(preorder_status:, count: 1, responsible_body: nil)
  rb = responsible_body || create(:trust, :devolves_management)
  schools = if count == 1
              [create(:school, responsible_body: rb)]
            else
              create_list(:school, count, responsible_body: rb)
            end

  case preorder_status
  when 'needs_info'
    schools.each do |school|
      school.responsible_body.update!(who_will_order_devices: 'responsible_body')
      create(:preorder_information, :rb_will_order, school: school)
    end
  when 'needs_contact'
    schools.each do |school|
      create(:preorder_information, :school_will_order, school: school)
    end
  when 'school_will_be_contacted'
    schools.each do |school|
      create(:preorder_information, :school_will_order,
             school_contact: create(:school_contact), school: school)
    end
  when 'school_contacted'
    schools.each do |school|
      create(:preorder_information, :school_will_order, school: school)
      school.users << create(:school_user)
    end
  when 'school_can_order'
    schools.each do |school|
      create(:preorder_information, :school_will_order, :does_not_need_chromebooks, school: school)
      school.users << create(:school_user)
      create(:school_device_allocation, :with_std_allocation, :with_available_devices, school: school)
      create(:school_device_allocation, :with_coms_allocation, school: school)
      school.can_order!
    end
  when 'ordered'
    schools.each do |school|
      create(:preorder_information, :school_will_order, :does_not_need_chromebooks, school: school)
      school.users << create(:school_user)
      create(:school_device_allocation, :with_std_allocation, school: school, cap: 10, devices_ordered: 10, allocation: 10)
      create(:school_device_allocation, :with_coms_allocation, school: school)
    end
  when 'school_ready'
    schools.each do |school|
      create(:preorder_information, :school_will_order, :does_not_need_chromebooks, school: school)
      school.users << create(:school_user)
      create(:school_device_allocation, :with_std_allocation, school: school)
      create(:school_device_allocation, :with_coms_allocation, school: school)
    end
  when 'rb_can_order'
    schools.each do |school|
      create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, school: school)
      school.users << create(:school_user)
      create(:school_device_allocation, :with_std_allocation, :with_available_devices, school: school)
      create(:school_device_allocation, :with_coms_allocation, school: school)
      school.responsible_body.update!(who_will_order_devices: 'responsible_body')
      school.can_order!
    end
  when 'ready'
    schools.each do |school|
      create(:preorder_information, :rb_will_order, :does_not_need_chromebooks, school: school)
      school.users << create(:school_user)
      create(:school_device_allocation, :with_std_allocation, school: school)
      create(:school_device_allocation, :with_coms_allocation, school: school)
      school.responsible_body.update!(who_will_order_devices: 'responsible_body')
    end
  else
    raise "Unknown preorder_status '#{preorder_status}'"
  end
  schools.each do |school|
    school.reload
    school.preorder_information.refresh_status!
    expect(school.preorder_information.status).to eq(preorder_status)
  end
  schools.count == 1 ? schools.first : schools
end

def create_and_put_school_in_pool(responsible_body)
  create(:school, :centrally_managed, responsible_body: responsible_body).tap do |school|
    create(:school_device_allocation, :with_std_allocation, school: school, allocation: rand(10..20), cap: rand(1..9), devices_ordered: rand(1..9))
    create(:school_device_allocation, :with_coms_allocation, school: school, allocation: rand(10..10), cap: rand(1..9), devices_ordered: rand(1..9))
    put_school_in_pool(responsible_body, school)
  end
end

def put_school_in_pool(responsible_body, pool_school)
  pool_school.preorder_information.responsible_body_will_order_devices!
  pool_school.can_order!
  responsible_body.add_school_to_virtual_cap_pools!(pool_school)
end
