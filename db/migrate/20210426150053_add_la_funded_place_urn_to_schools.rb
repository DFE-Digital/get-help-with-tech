class AddLaFundedPlaceUrnToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :provision_urn, :string
    add_column :schools, :provision_type, :string
    add_index :schools, :provision_urn, unique: true
  end
end
