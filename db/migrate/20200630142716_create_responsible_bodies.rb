class CreateResponsibleBodies < ActiveRecord::Migration[6.0]
  def change
    create_table :responsible_bodies do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :organisation_type, null: false
      t.string :local_authority_official_name
      t.string :local_authority_eng
      t.string :companies_house_number

      t.timestamps
    end
  end
end
