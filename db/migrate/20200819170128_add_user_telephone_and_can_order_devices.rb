class AddUserTelephoneAndCanOrderDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :telephone, :string
  end
end
