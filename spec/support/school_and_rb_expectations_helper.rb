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
      expect(school).to be_vcap

      expect_vcap_to_be(rb_id: responsible_body.id,
                        laptop_allocation:,
                        laptop_cap:,
                        laptops_ordered:,
                        router_allocation:,
                        router_cap:,
                        routers_ordered:)
    else
      expect(school).not_to be_vcap
    end

    expect_school_to_be(school_id: school.id,
                        laptop_allocation:,
                        laptop_cap:,
                        laptops_ordered:,
                        router_allocation:,
                        router_cap:,
                        routers_ordered:,
                        centrally_managed:,
                        manages_orders:)

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

    expect(responsible_body).to be_vcap

    expect(responsible_body.allocation(:laptop)).to eq(laptop_allocation)
    expect(responsible_body.cap(:laptop)).to eq(laptop_cap)
    expect(responsible_body.devices_ordered(:laptop)).to eq(laptops_ordered)
    expect(responsible_body.allocation(:router)).to eq(router_allocation)
    expect(responsible_body.cap(:router)).to eq(router_cap)
    expect(responsible_body.devices_ordered(:router)).to eq(routers_ordered)
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

    expect(school.allocation(:laptop)).to eq(laptop_allocation)
    expect(school.cap(:laptop)).to eq(laptop_cap)
    expect(school.devices_ordered(:laptop)).to eq(laptops_ordered)
    expect(school.allocation(:router)).to eq(router_allocation)
    expect(school.cap(:router)).to eq(router_cap)
    expect(school.devices_ordered(:router)).to eq(routers_ordered)
  end
end

RSpec.configure do |c|
  c.include SchoolAndRbExpectationsHelper
end
