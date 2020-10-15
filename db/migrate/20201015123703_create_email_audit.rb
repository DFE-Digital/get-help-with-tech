class CreateEmailAudit < ActiveRecord::Migration[6.0]
  def change
    create_table :email_audits do |t|
      t.string :message_type, null: false, index: true
      t.string :template, null: false
      t.integer :school_urn
      t.string :email_address
      t.timestamps
    end
  end
end
