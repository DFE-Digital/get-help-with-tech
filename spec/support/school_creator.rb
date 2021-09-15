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
    school.refresh_device_ordering_status!
    expect(school.device_ordering_status).to eq(preorder_status)
  end
  schools.count == 1 ? schools.first : schools
end

def create_centrally_managed_school_that_can_order(responsible_body)
  create(:school, :manages_orders, responsible_body: responsible_body).tap do |school|
    create(:school_device_allocation, :with_std_allocation, school: school, allocation: rand(10..20), cap: rand(1..9), devices_ordered: rand(1..9))
    create(:school_device_allocation, :with_coms_allocation, school: school, allocation: rand(10..10), cap: rand(1..9), devices_ordered: rand(1..9))
    school.orders_managed_centrally!
    school.can_order!
  end
end
