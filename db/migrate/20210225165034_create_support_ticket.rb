class CreateSupportTicket < ActiveRecord::Migration[6.1]
  def change
    create_table :support_tickets do |t|
      t.references :user, foreign_key: true

      t.text :session_id, null: false

      t.text :user_type
      t.text :user_profile_path

      t.text :full_name
      t.text :email_address
      t.text :telephone_number

      t.text :school_name
      t.text :school_unique_id
      t.text :school_urn

      t.text :academy_name

      t.text :college_name
      t.text :college_ukprn

      t.text :local_authority_name

      t.text :support_topics, array: true, default: []

      t.text :message

      t.text :zendesk_ticket_id

      t.timestamps
    end

    add_index :support_tickets, :session_id
  end
end
