class CreateComputacenterUserChanges < ActiveRecord::Migration[6.0]
  def change
    create_table :computacenter_user_changes do |t|
      t.integer :user_id
      t.text :first_name
      t.text :last_name
      t.text :email_address
      t.text :telephone
      t.text :responsible_body
      t.text :responsible_body_urn
      t.text :cc_sold_to_number
      t.text :school
      t.text :school_urn
      t.text :cc_ship_to_number
      t.datetime :updated_at_timestamp
      t.integer :type_of_update
      t.text :original_email_address

      t.timestamps
    end

    add_index :computacenter_user_changes, :user_id
    add_index :computacenter_user_changes, :updated_at_timestamp
  end
end
