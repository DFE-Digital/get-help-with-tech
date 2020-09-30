class AddCcImportAPIFieldsToUserChange < ActiveRecord::Migration[6.0]
  def change
    add_column :computacenter_user_changes, :cc_import_api_timestamp, :datetime, null: true
    add_column :computacenter_user_changes, :cc_import_api_transaction_id, :string, null: true

    add_index :computacenter_user_changes, :cc_import_api_timestamp, name: 'ix_cc_user_changes_timestamp'
    add_index :computacenter_user_changes, :cc_import_api_transaction_id, name: 'ix_cc_user_changes_cc_tx_id'
  end
end
