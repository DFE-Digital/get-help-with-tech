class MakeCreatedByAndLastUpdatedByUserIdOptional < ActiveRecord::Migration[6.0]
  def change
    remove_reference :school_device_allocations, :last_updated_by_user
    remove_reference :school_device_allocations, :created_by_user

    add_reference :school_device_allocations, :last_updated_by_user, class_name: 'User', null: true
    add_reference :school_device_allocations, :created_by_user, class_name: 'User', null: true
  end
end
