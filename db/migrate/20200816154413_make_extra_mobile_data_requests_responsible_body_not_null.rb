class MakeExtraMobileDataRequestsResponsibleBodyNotNull < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :extra_mobile_data_requests, :responsible_body_id, :integer, null: false
      end
      dir.down do
        change_column :extra_mobile_data_requests, :responsible_body_id, :integer, null: true
      end
    end
  end
end
