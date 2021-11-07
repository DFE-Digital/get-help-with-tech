class ReplaceRawCapFieldsFromSchools < ActiveRecord::Migration[6.1]
  def up
    add_column :schools, :circumstances_laptops, :integer, default: 0, null: false
    add_column :schools, :circumstances_routers, :integer, default: 0, null: false
    add_column :schools, :over_order_reclaimed_laptops, :integer, default: 0, null: false
    add_column :schools, :over_order_reclaimed_routers, :integer, default: 0, null: false
    populate_new_fields
    remove_column :schools, :raw_laptop_cap, :integer, default: 0, null: false
    remove_column :schools, :raw_router_cap, :integer, default: 0, null: false
  end

  def down
    add_column :schools, :raw_laptop_cap, :integer, default: 0, null: false
    add_column :schools, :raw_router_cap, :integer, default: 0, null: false
    populate_raw_cap_fields
    remove_column :schools, :circumstances_laptops, :integer, default: 0, null: false
    remove_column :schools, :circumstances_routers, :integer, default: 0, null: false
    remove_column :schools, :over_order_reclaimed_laptops, :integer, default: 0, null: false
    remove_column :schools, :over_order_reclaimed_routers, :integer, default: 0, null: false
  end

private

  def populate_new_fields
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
    School.update_all('raw_laptop_cap = raw_laptop_allocation + over_order_reclaimed_laptops + circumstances_laptops')
    School.update_all('raw_router_cap = raw_router_allocation + over_order_reclaimed_routers + circumstances_routers')
  end
end
