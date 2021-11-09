class MigrateOverOrdersData
  def populate_new_fields
    School.cannot_order.update_all('raw_laptop_cap = raw_laptop_allocation')
    School.cannot_order.update_all('raw_router_cap = raw_router_allocation')
    School.update_all("over_order_reclaimed_laptops = (CASE
                                                           WHEN raw_laptops_ordered > raw_laptop_allocation
                                                              THEN raw_laptop_cap - raw_laptop_allocation
                                                           WHEN order_state = 'can_order_for_specific_circumstances'
                                                              THEN 0
                                                           ELSE raw_laptop_cap - raw_laptop_allocation
                                                       END)")
    School.update_all('circumstances_laptops = raw_laptop_cap - (raw_laptop_allocation + over_order_reclaimed_laptops)')
    School.update_all("over_order_reclaimed_routers = (CASE
                                                           WHEN raw_routers_ordered > raw_router_allocation
                                                              THEN raw_router_cap - raw_router_allocation
                                                           WHEN order_state = 'can_order_for_specific_circumstances'
                                                              THEN 0
                                                           ELSE raw_router_cap - raw_router_allocation
                                                       END)")
    School.update_all('circumstances_routers = raw_router_cap - (raw_router_allocation + over_order_reclaimed_routers)')
  end

  def populate_raw_cap_fields
    School.update_all("raw_laptop_cap = CASE order_state
                                            WHEN 'cannot_order' THEN raw_laptops_ordered
                                            ELSE raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops
                                        END")
    School.update_all("raw_router_cap = CASE order_state
                                            WHEN 'cannot_order' THEN raw_routers_ordered
                                            ELSE raw_router_allocation + over_order_reclaimed_routers + circumstances_routers
                                        END")
  end
end

namespace :db do
  desc 'Migrate over-orders data'
  task migrate_over_orders_data: :environment do
    migrate = MigrateOverOrdersData.new
    migrate.populate_new_fields
  end
end
