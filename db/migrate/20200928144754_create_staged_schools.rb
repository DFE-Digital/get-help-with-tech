class CreateStagedSchools < ActiveRecord::Migration[6.0]
  def change
    create_table :staged_schools do |t|
      t.integer :urn, null: false, index: true
      t.string :name, null: false, index: true
      t.string :responsible_body_name, null: false
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :town
      t.string :county
      t.string :postcode
      t.string :phase, null: false
      t.string :establishment_type
      t.string :status, null: false, index: true
      t.integer :link_urn
      t.string :link_type
      t.timestamps
    end
  end
end
