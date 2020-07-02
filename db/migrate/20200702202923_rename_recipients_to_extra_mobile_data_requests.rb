class RenameRecipientsToExtraMobileDataRequests < ActiveRecord::Migration[6.0]
  def change
    # the rename_table would normally also rename the index, but the default
    # index name upon rename is longer than 63 characters, so it has to be done
    # by hand
    rename_index :recipients, :index_recipients_on_mobile_network_id_and_status_and_created_at, :index_emdr_on_mobile_network_id_and_status_and_created_at

    rename_table :recipients, :extra_mobile_data_requests
  end
end
