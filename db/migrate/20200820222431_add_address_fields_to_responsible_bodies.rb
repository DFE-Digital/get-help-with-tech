class AddAddressFieldsToResponsibleBodies < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :address_1, :string
    add_column :responsible_bodies, :address_2, :string
    add_column :responsible_bodies, :address_3, :string
    add_column :responsible_bodies, :town, :string
    add_column :responsible_bodies, :postcode, :string
  end
end
