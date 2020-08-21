class CreateSchoolContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :school_contacts do |t|
      t.references :school, null: false, index: true
      t.string :email_address, null: false
      t.string :full_name, null: false
      t.string :role
      t.string :title
      t.string :phone_number
      t.timestamps
    end

    add_index :school_contacts, %i[school_id email_address], unique: true
  end
end
