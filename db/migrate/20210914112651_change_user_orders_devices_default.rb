class ChangeUserOrdersDevicesDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :orders_devices, false # rubocop:disable Rails/ReversibleMigration
  end
end
