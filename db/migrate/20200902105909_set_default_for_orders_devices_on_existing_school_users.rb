class SetDefaultForOrdersDevicesOnExistingSchoolUsers < ActiveRecord::Migration[6.0]
  def change
    connection.execute <<~SQL
      UPDATE users
      SET orders_devices = false
      WHERE orders_devices IS NULL
      AND school_id IS NOT NULL
    SQL
  end
end
