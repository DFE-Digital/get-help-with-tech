class AddAddressToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :address_1, :string
    add_column :schools, :address_2, :string
    add_column :schools, :address_3, :string
    add_column :schools, :town, :string
    add_column :schools, :county, :string
    add_column :schools, :postcode, :string
  end
end
