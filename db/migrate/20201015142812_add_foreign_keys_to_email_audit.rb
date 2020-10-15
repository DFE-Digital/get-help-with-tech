class AddForeignKeysToEmailAudit < ActiveRecord::Migration[6.0]
  def change
    add_reference :email_audits, :user, index: true
    add_reference :email_audits, :school, index: true
    remove_column :email_audits, :school_urn, :integer
  end
end
