module SchoolAndRbExpectationsHelper
  require_relative './computacenter_helper'

  def expect_school_to_be_in_rb(school_id:,
                                rb_id:,
                                vcap:,
                                laptop_allocation:,
                                laptop_cap:,
                                laptops_ordered:,
                                router_allocation:,
                                router_cap:,
                                routers_ordered:,
                                centrally_managed:,
                                manages_orders:,
                                requests: false)
    responsible_body = ResponsibleBody.find(rb_id)
    school = School.find(school_id)

    expect(school.responsible_body).to eq(responsible_body)

    if vcap
      expect(school).to be_in_virtual_cap_pool(responsible_body_id: responsible_body.id)

      expect_vcap_to_be(rb_id: responsible_body.id,
                        laptop_allocation: laptop_allocation,
                        laptop_cap: laptop_cap,
                        laptops_ordered: laptops_ordered,
                        router_allocation: router_allocation,
                        router_cap: router_cap,
                        routers_ordered: routers_ordered)
    else
      expect(school).not_to be_in_virtual_cap_pool
    end

    expect_school_to_be(school_id: school.id,
                        laptop_allocation: laptop_allocation,
                        laptop_cap: laptop_cap,
                        laptops_ordered: laptops_ordered,
                        router_allocation: router_allocation,
                        router_cap: router_cap,
                        routers_ordered: routers_ordered,
                        centrally_managed: centrally_managed,
                        manages_orders: manages_orders)

    expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false) if requests
  end

  def expect_vcap_to_be(rb_id:,
                        laptop_allocation:,
                        laptop_cap:,
                        laptops_ordered:,
                        router_allocation:,
                        router_cap:,
                        routers_ordered:)
    responsible_body = ResponsibleBody.find(rb_id)

    expect(responsible_body).to have_virtual_cap_feature_flags

    expect(responsible_body.laptop_allocation).to eq(laptop_allocation)
    expect(responsible_body.laptop_cap).to eq(laptop_cap)
    expect(responsible_body.laptops_ordered).to eq(laptops_ordered)
    expect(responsible_body.router_allocation).to eq(router_allocation)
    expect(responsible_body.router_cap).to eq(router_cap)
    expect(responsible_body.routers_ordered).to eq(routers_ordered)
  end

  def expect_school_to_be(school_id:,
                          laptop_allocation:,
                          laptop_cap:,
                          laptops_ordered:,
                          router_allocation:,
                          router_cap:,
                          routers_ordered:,
                          centrally_managed:,
                          manages_orders:)
    school = School.find(school_id)

    if centrally_managed
      expect(school).to be_orders_managed_centrally
    else
      expect(school).not_to be_orders_managed_centrally
    end

    if manages_orders
      expect(school).to be_orders_managed_by_school
    else
      expect(school).not_to be_orders_managed_by_school
    end

    expect(school.laptop_allocation).to eq(laptop_allocation)
    expect(school.laptop_cap).to eq(laptop_cap)
    expect(school.laptops_ordered).to eq(laptops_ordered)
    expect(school.router_allocation).to eq(router_allocation)
    expect(school.router_cap).to eq(router_cap)
    expect(school.routers_ordered).to eq(routers_ordered)
  end
end

RSpec.configure do |c|
  c.include SchoolAndRbExpectationsHelper
end
