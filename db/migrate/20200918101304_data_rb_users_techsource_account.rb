class DataRbUsersTechsourceAccount < ActiveRecord::Migration[6.0]
  def up
    User.responsible_body_users.update(orders_devices: true)
  end

  def down
    # this migration cannot be reversed
  end
end
