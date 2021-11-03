class CapChangesForOverOrderedSchools < ActiveRecord::Migration[6.1]
  def change
    rename_table :allocation_changes, :cap_changes
    rename_column :cap_changes, :prev_allocation, :prev_cap
    rename_column :cap_changes, :new_allocation, :new_cap
    change_column_null :cap_changes, :prev_cap, false, default: 0
    change_column_null :cap_changes, :new_cap, false, default: 0
    change_column_default :cap_changes, :prev_cap, from: nil, to: 0
    change_column_default :cap_changes, :new_cap, from: nil, to: 0

    restore_school_assigned_allocations
  end

  private

  def restore_school_assigned_allocations
    School.includes(:cap_changes).find_each do |school|
      changes_by_device_type = school.cap_changes.group_by(&:device_type)
      props_to_update = {
        raw_laptop_allocation: changes_by_device_type[:laptop]&.sort_by(:created_at)&.first&.prev_cap,
        raw_router_allocation: changes_by_device_type[:router]&.sort_by(:created_at)&.first&.prev_cap
      }.compact!
      school.update_columns(**props_to_update) if props_to_update.present?
    end
  end
end
