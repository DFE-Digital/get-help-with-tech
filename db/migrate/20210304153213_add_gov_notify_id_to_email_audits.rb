class AddGovNotifyIdToEmailAudits < ActiveRecord::Migration[6.1]
  def change
    add_column :email_audits, :govuk_notify_id, :text, null: true
    add_column :email_audits, :govuk_notify_status, :text, null: true

    change_column_null :email_audits, :template, true

    add_index :email_audits, :govuk_notify_id
  end
end
