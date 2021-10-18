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
      school.update!(who_will_order_devices: :responsible_body)
    end
  when 'needs_contact'
    schools.each do |school|
      school.update!(who_will_order_devices: :school)
    end
  when 'school_will_be_contacted'
    schools.each do |school|
      school_contact = create(:school_contact, school: school)
      school.update!(who_will_order_devices: :school, school_contact: school_contact)
    end
  when 'school_contacted'
    schools.each do |school|
      school.update!(who_will_order_devices: :school)
      create(:school_user, school: school)
    end
  when 'school_can_order'
    schools.each do |school|
      school.update!(who_will_order_devices: :school,
                     will_need_chromebooks: :no,
                     raw_laptop_allocation: 2,
                     raw_laptop_cap: 1,
                     raw_laptops_ordered: 0,
                     raw_router_allocation: 1,
                     raw_router_cap: 0,
                     raw_routers_ordered: 0)
      create(:school_user, school: school)
      school.can_order!
    end
  when 'ordered'
    schools.each do |school|
      school.update!(who_will_order_devices: :school,
                     will_need_chromebooks: :no,
                     raw_laptop_allocation: 10,
                     raw_laptop_cap: 10,
                     raw_laptops_ordered: 10,
                     raw_router_allocation: 1,
                     raw_router_cap: 0,
                     raw_routers_ordered: 0)
      create(:school_user, school: school)
    end
  when 'school_ready'
    schools.each do |school|
      school.update!(who_will_order_devices: :school,
                     will_need_chromebooks: :no,
                     raw_laptop_allocation: 1,
                     raw_laptop_cap: 0,
                     raw_laptops_ordered: 0,
                     raw_router_allocation: 1,
                     raw_router_cap: 0,
                     raw_routers_ordered: 0)
      create(:school_user, school: school)
    end
  when 'rb_can_order'
    schools.each do |school|
      school.update!(who_will_order_devices: :responsible_body,
                     will_need_chromebooks: :no,
                     raw_laptop_allocation: 2,
                     raw_laptop_cap: 1,
                     raw_laptops_ordered: 0,
                     raw_router_allocation: 1,
                     raw_router_cap: 0,
                     raw_routers_ordered: 0)
      create(:school_user, school: school)
      school.responsible_body.update!(who_will_order_devices: 'responsible_body')
      school.can_order!
    end
  when 'ready'
    schools.each do |school|
      school.update!(who_will_order_devices: :responsible_body,
                     will_need_chromebooks: :no,
                     raw_laptop_allocation: 1,
                     raw_laptop_cap: 0,
                     raw_laptops_ordered: 0,
                     raw_router_allocation: 1,
                     raw_router_cap: 0,
                     raw_routers_ordered: 0)
      create(:school_user, school: school)
      school.responsible_body.update!(who_will_order_devices: 'responsible_body')
    end
  else
    raise "Unknown preorder_status '#{preorder_status}'"
  end
  schools.each do |school|
    school.reload
    school.refresh_preorder_status!
    expect(school.preorder_status).to eq(preorder_status)
  end
  schools.count == 1 ? schools.first : schools
end

def create_centrally_managed_school_that_can_order(responsible_body)
  create(:school, :manages_orders, responsible_body: responsible_body).tap do |school|
    school.update!(raw_laptop_allocation: rand(10..20),
                   raw_laptop_cap: rand(1..9),
                   raw_laptops_ordered: rand(1..9),
                   raw_router_allocation: rand(10..10),
                   raw_router_cap: rand(1..9),
                   raw_routers_ordered: rand(1..9))
    SchoolSetWhoManagesOrdersService.new(school, :responsible_body).call
    school.can_order!
  end
end
