class CreateStagedTrusts < ActiveRecord::Migration[6.0]
  def change
    create_table :staged_trusts do |t|
      t.string :name, null: false, index: true
      t.string :organisation_type, null: false
      t.string :gias_group_uid, null: false
      t.string :companies_house_number
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :town
      t.string :county
      t.string :postcode
      t.string :status, null: false, index: true
      t.timestamps
    end
    add_index :staged_trusts, :gias_group_uid, unique: true
  end
end
